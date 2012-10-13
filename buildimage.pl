#!/usr/bin/perl
#
#  Script to create a Bering-uClibc disk image from existing packages
#
#  Copyright (C) 2010, 2011, 2012 David M Brooke, davidmbrooke@users.sourceforge.net
#  Based on buildpacket.pl by Martin Hejl
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
use strict;
use warnings;
use Config::General;
use Getopt::Long;
use Date::Format;
use File::Spec;
use File::Temp;
use File::Copy;
use Carp;
use FindBin qw($Bin);       # where was script installed?
use lib $FindBin::Bin;      # use that dir for libs, too

use buildtool::Tools
  qw< make_absolute_path create_dir remove_dir readBtGlobalConfig readBtConfig >;

my %configHash = ( );
my $relver;
my $image;
my $verbose = 0;
my $keeptmp = 0;
my $debug;
my $tmpDir;
my $Usage =
qq{Usage: $0 --image=ImgDir [--relver=VersionLabel] [--verbose] [--keeptmp]
   image      Parent directory for buildimage.cfg, under buildtool/image
              e.g. Bering-uClibc_i486_isolinux_vga
   relver     [Optional] String to append to image name to show release version
              e.g. 4.0beta1. Use version defined in initrd package by default
   verbose    [Optional] Report progress during execution
   keeptmp    [Optional] Do not delete temporary directory
};

sub createTempDir;
sub cleanTempDir;
sub system_exec;
sub createDirUnlessItExists;
sub copyFilesToTempDir;
sub copyFilesWithSearchAndReplace;

# Process command line arguments
GetOptions(
    "verbose!" => \$verbose,
    "image=s"  => \$image,
    "relver=s" => \$relver,
    "keeptmp!" => \$keeptmp,
    "debug!"   => \$debug
) or die $Usage;

die $Usage unless defined( $image );

$SIG{'INT'} = 'CLEANUP';

my $baseDir	= File::Spec->rel2abs($FindBin::Bin);

# Check we are running as (fake)root
warn "WARNING: Not running as (fake)root" if ( $> != 0 );

# Fetch the buildtool config
my $buildtoolconf = File::Spec->catfile( $baseDir, 'conf', 'buildtool.conf' );
my %btConfig = readBtGlobalConfig(
    ConfigFile  => $buildtoolconf,
    ForceConfig => {
        'root_dir' => $baseDir,    # inject root_dir
    }
);

# Fetch the global config (conf/sources.cfg)
my $glConfig = new Config::General(
    "-ConfigFile" =>
      make_absolute_path( $btConfig{'globalconffile'}, $baseDir ),
    '-IncludeRelative' => 1,
    '-IncludeGlob'     => 1,
    "-LowerCaseNames"  => 1,
    "-ExtendedAccess"  => 1
);

# Fetch the image specific config (${image_dir}/buildimage.cfg)
my $imConfig = new Config::General(
    "-ConfigFile" => File::Spec->catfile(
        $btConfig{'image_dir'}, $image, $btConfig{'buildimage_config'}
    ),
    "-LowerCaseNames" => 1,
    "-ExtendedAccess" => 1
);

# Generate date label
$configHash{ '{DATE}' } = time2str( "%Y-%m-%d", time );
print "Build Date is:\t\t$configHash{ '{DATE}' }\n" if $verbose;

# Extract image name, type, kernel arch, suffix and toolchain from config file
my $imageStruc = $imConfig->value('image');
my $imgName    = $imageStruc->{'imagename'};
die "ERROR: ImageName is not specified in config file" unless defined $imgName;
print "Image name:\t\t$imgName\n" if $verbose;
my $kernelArch = $imageStruc->{ 'kernelarch' };
die "ERROR: KernelArch is not specified in config file" unless defined $kernelArch;
print "Kernel Arch:\t\t$kernelArch\n" if $verbose;
my $imgType = $imageStruc->{ 'imagetype' };
die "ERROR: ImageType is not specified in config file" unless defined $imgType;
print "Image type:\t\t$imgType\n" if $verbose;
my $imgSuffix = $imageStruc->{ 'imagesuffix' };
die "ERROR: ImageSuffix is not specified in config file" unless defined $imgSuffix;
print "Image Suffix:\t\t$imgSuffix\n" if $verbose;
my $toolchain = $imageStruc->{ 'toolchain' };
die "ERROR: Toolchain is not specified in config file" unless defined $toolchain;
print "Toolchain name:\t\t$toolchain\n" if $verbose;

# Reread the config file with the right toolchain
my %force_config = ();
$force_config{'toolchain'} = $toolchain;
%btConfig = readBtGlobalConfig(
    ConfigFile  => $buildtoolconf,
    ForceConfig => {
        %force_config,
        'root_dir' => $baseDir,    # inject root_dir
    }
);

my $sourceDir  = make_absolute_path( $btConfig{'source_dir'},  $baseDir );
my $stagingDir = make_absolute_path( $btConfig{'staging_dir'}, $baseDir );

# Extract kernel version from source tree
my $kconfig =
  File::Spec->catfile( $sourceDir, 'linux', "linux-${kernelArch}", '.config' );
my $kver;
die "ERROR: No kernel .config file at $kconfig" unless ( -r $kconfig );
open( FH, "<".$kconfig );
while ( <FH> )
{ if ( /Linux\/\w+ ([0-9.]+) Kernel Configuration/ ) { $kver = $1; last; } }
close( FH );
print "Kernel Version is:\t$kver\n" if $verbose;

# Check if modules exists
my $modules_dir =
  File::Spec->catdir( $stagingDir, 'lib', 'modules', "${kver}-${kernelArch}" );
die "Error: can't find kernel modules in $modules_dir\n" unless -d $modules_dir;

# If no relver was specified on the command line
unless ($relver) {
    # fetch the release version from the initrd package
    my %initrdConfig = readBtConfig(
        "ConfigFile" => File::Spec->catfile(
            $sourceDir, 'initrd', $btConfig{'buildtool_config'}
        ),
    );
    $relver = $initrdConfig{package}->{initrd}->{version}
      or die "Can't extract release version from initrd package\n";
}
$configHash{'{VERSION}'} = $relver;

# Create directory to hold image contents
$tmpDir = createTempDir( );

# Set environment variables
for my $var (keys %{ $btConfig{envvars} }) {
    $ENV{$var} = $btConfig{envvars}->{$var};
}

# Check if the config file specifies a path for modules.tgz & firmware.tgz files
my $modTgzPath = $imageStruc->{ 'modtgzpath' };
$modTgzPath = "/" unless defined $modTgzPath;
print "modules.tgz path:\t$modTgzPath\n" if $verbose;

# Ensure that destination directory for modules.tgz & firmware.tgz exists
create_dir( File::Spec->catdir( $tmpDir, $modTgzPath ) );

# Always create full modules.tgz
print "Creating modules.tgz...\n" if $verbose;
system_exec(
    "cd $modules_dir && tar -czf ${tmpDir}/${modTgzPath}/modules.tgz * --exclude=build --exclude=source --exclude=modules.*",
    "ERROR: Failed to build modules.tgz"
);

# Always create full firmware.tgz
print "Creating firmware.tgz...\n" if $verbose;
system_exec(
    "cd ${stagingDir}/lib/firmware && tar -czf ${tmpDir}/${modTgzPath}/firmware.tgz *",
    "ERROR: Failed to build firmware.tgz"
);

# Extract configuration variables from config file
# Populate global configHash with Search-And-Replace Key:Value
while ( my ( $key, $value ) = each( %{ $imageStruc->{'config'} } ) ) {
    my $ucKey = $key;
    $ucKey =~ tr/[a-z]/[A-Z]/;
    $configHash{$ucKey} = $value;
}

# Process <Contents> block from config file
my $imageContents = $imageStruc->{ 'contents' };

# Should be exactly one <Kernel> block
my $imageKernel = $imageContents->{ 'kernel' };
die "ERROR: <Kernel> entry not present in config file" unless defined $imageKernel;
copyFilesToTempDir(
    $imageKernel->{ 'source' },
    $imageKernel->{ 'filename' } );
# Capture path to kernel to use in sys/isolinux.cfg
$configHash{ '{KERNEL}' } = "/".$imageKernel->{ 'filename' } ;

# Should be multiple <File> blocks
# Don't even bother coping with the case of a single <File> block
foreach my $fileStruc ( @{ $imageContents->{'file'} } ) {
    print "DEBUG - Processing block for <File> ", $fileStruc->{'filename'}, "\n"
      if $debug;

    # Do we need to Search-And-Replace strings in this file?
    if ( defined( $fileStruc->{'searchandreplace'} ) ) {

        # Yes; need to Search-And-Replace for this file entry
        # We have an ARRAY if there is >1 SearchAndReplace entry for this file
        if ( ref( $fileStruc->{'searchandreplace'} ) eq 'ARRAY' ) {
            print "DEBUG - Processing multiple S&R strings\n" if $debug;
            my @sAndR = @{ $fileStruc->{'searchandreplace'} };
            copyFilesWithSearchAndReplace( $fileStruc->{'source'},
                $fileStruc->{'filename'}, @sAndR );
        }

        # We have a SCALAR if there is 1 SearchAndReplace entry for this file
        else {
            print "DEBUG - Processing single S&R strings\n" if $debug;
            my @sAndR = ( $fileStruc->{'searchandreplace'} );
            copyFilesWithSearchAndReplace( $fileStruc->{'source'},
                $fileStruc->{'filename'}, @sAndR );
        }
    }
    else {
        # No; no need to Search-And-Replace for this entry - just copy file
        copyFilesToTempDir( $fileStruc->{'source'}, $fileStruc->{'filename'} );
    }
}

# Complete the processing depending on the image type specified
print "Performing ".$imgType." processing...\n" if $verbose;
my $fileBase = File::Spec->catfile( $btConfig{'image_dir'}, $image,
        $imgName . "_"
      . $relver . "_"
      . $kernelArch . "_"
      . $imgType . "_"
      . $imgSuffix );

if ( $imgType eq "syslinux" || $imgType eq "pxelinux" ) {
    my $fileName = $fileBase . ".tar.gz";
    system_exec(
        "tar -C $tmpDir -czf $fileName .",
        "ERROR: Failed to create image tarfile: $!"
    );
}
elsif ( $imgType eq "isolinux" ) {
    my $fileName = $fileBase . ".iso";
    # Summary of mkisofs arguments:
    #  -o		Name of generated image file
    #  -v		Verbose messages
    #  -b		El Torito boot image filename
    #  -no-emul-boot	CD-ROM is not a disk image; do not emulate a disk
    #  -c             	Name of boot catalog  file to be generated by mkisofs
    #  -boot-load-size	Number of 512-byte sectors to load in no-emul mode
    #  -boot-info-table	Include a table of the image file layout
    #  -l		Allow long (31-character) filenames
    #  -R		Use Rock Ridge extensions
    #  -r		Use standard values for file ownership and permissions
    #  .		Create image of current directory
    system_exec(
        "cd $tmpDir ; mkisofs -o $fileName -v -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -l -R -r .",
        "ERROR: Failed running mkisofs: $!"
    );

}
else {
    die "ERROR: Unsupported image type $imgType\n";
}

END {
    # Tidyup
    cleanTempDir if $tmpDir;
}

# End of main

sub CLEANUP {
    print "\n\nCaught Interrupt (^C), Aborting\n";
    cleanTempDir if $tmpDir;
    exit(1);
}

sub createTempDir {
    my $tempDIR;
    eval {
        $tempDIR =
          File::Temp::tempdir( 'BUILDIMAGE_STAGING_XXXX', 'TMPDIR' => 1 );
    };
    if ( $@ ne '' ) {
        confess("Unable to create temporary directory. $@");
    }
    print "Temporary directory:\t$tempDIR\n" if $verbose;
    return $tempDIR;
}

sub cleanTempDir {
    return if $keeptmp;
    print "Cleaning up dir $tmpDir\n" if $verbose;
    confess("Temp dir undefined") unless defined($tmpDir);
    confess("Will not delete root dir")
      if File::Spec->canonpath($tmpDir) eq File::Spec->rootdir();
    remove_dir $tmpDir;
}

sub system_exec {
    my ( $command, $error_message, $no_cleanup ) = @_;
    $no_cleanup = 0 unless defined($no_cleanup);
    $error_message = "$command failed " unless defined($error_message);
    print "Executing $command\n" if $verbose;
    my $retVal = system($command );
    if ( $retVal >> 8 != 0 ) {

        # As a Special Case, do not exit if simply unable to copy files
        if ( $command =~ "^cp " ) {
            warn "WARNING: File not found executing $command";
        }
        else {
            cleanTempDir() unless $no_cleanup;
            confess("$error_message $!");
        }
    }
}

sub createDirUnlessItExists {
    my ($path) = @_;
    while ( !( -e $path ) ) {
        my @dirs        = File::Spec->splitdir($path);
        my $dirToCreate = "";
        foreach my $dir (@dirs) {
            $dirToCreate = File::Spec->catdir( $dirToCreate, $dir );
            if ( !( -e $dirToCreate ) ) {
                print "Creating directory $dirToCreate\n" if $verbose;
                mkdir($dirToCreate)
                  or confess( "creating dir " . $path . " failed. $!" );
            }
        }
    }
}

sub copyFilesToTempDir {
    my ( $source, $target ) = @_;
    my $absSource = File::Spec->catdir( $baseDir, $source );
    my $absTarget = File::Spec->catdir( $tmpDir,  $target );

    # Substitute environment variables like $GNU_TARGET_NAME in absSource
    $absSource =~ s/\$(\w+)/$ENV{$1}/g;

    # Check for '*' in Source
    if ( $absSource =~ /\*/ ) {
        # Source contains '*' so Target _must_ be a directory
        createDirUnlessItExists($absTarget);
        system_exec( "cp -r $absSource $absTarget",
            "Failed to copy files: $!" );
    }
    else {
        # Source does not contain '*' so Target is a file
        # Might still need to create the directory for that file
        my $destDir = File::Basename::dirname($absTarget);
        createDirUnlessItExists($destDir);
        system_exec( "cp -r $absSource $absTarget",
            "Failed to copy files: $!" );
    }
}

sub copyFilesWithSearchAndReplace {
    my ( $source, $target, @sAndR ) = @_;
    my $absSource = File::Spec->catdir( $baseDir, $source );
    my $absTarget = File::Spec->catdir( $tmpDir,  $target );

    # Check for '*' in Source
    if ( $absSource =~ /\*/ ) {
        # Source contains '*' so Target _must_ be a directory
        createDirUnlessItExists($absTarget);
        die
          "ERROR: Copying multiple files with SearchAndReplace is not currently supported. Sorry.";
    }
    else {
        # Source does not contain '*' so Target is a file
        # Might still need to create the directory for that file
        my $destDir = File::Basename::dirname($absTarget);
        createDirUnlessItExists($destDir);
        open( IFH, "<" . $absSource ) or confess("Error: $!");
        open( OFH, ">" . $absTarget ) or confess("Error: $!");
        while (<IFH>) {
            foreach my $string (@sAndR) {
                s/$string/$configHash{ $string }/;
            }
            print OFH;
        }
        close(OFH);
        close(IFH);
    }
}

exit;

__END__

=pod

=head1 NAME

buildimage.pl - create a Bering-uClibc disk image

=head1 SYNOPSIS

B<buildimage.pl> --image=ImgDir [--relver=VersionLabel] [--verbose] [--keeptmp]

   image      Parent directory for buildimage.cfg, under buildtool/image
              e.g. Bering-uClibc-isolinux-std
   relver     [Optional] String to append to image name to show release version
              e.g. 4.0beta1. Use version defined in initrd package by default
   verbose    [Optional] Report progress during execution
   keeptmp    [Optional] Do not delete temporary directory

=head1 DESCRIPTION

B<buildimage.pl> creates a Bering-uClibc disk image based on parameter
settings defined in a configuration file (buildimage.cfg) located within a
sub-directory of $BT_ROOT/image/. The name of this sub-directory is specified
with the "--image" command-line argument.

The disk image can be for SYSLINUX (suitable for writing to a flash drive),
PXELINUX (suitable for network booting) or can use ISOLINUX.
The choice between these is specified in buildimage.cfg.

For SYSLINUX and PXELINUX, the "image" is a .tar.gz file which needs to be
extracted onto suitably prepared media or installed on a PXELINUX server.
For ISOLINUX the "image" is a .iso file which can be burned to a CD-R disk.

Note that the name of the generated image file is derived from entries in the
configuration file rather than from the --image command-line argument.

The generated image name is formed from:
   - The value of the ImageName entry in the configuration file
       Typically "Bering-uClibc"
   - The value of the --relver command-line argument
       Something like "4.0-beta1"
   - The value of the KernelArch entry in the configuration file
       Something like "i686"
   - The value of the ImageType entry in the configuration file
       Something like "syslinux"
   - The value of the ImageSuffix entry in the configuration file
       A free-format string like "vga" or "ser"

Each of these is separated by an underscore character (_).
In addition, a file extension based on ImageType is appended (e.g. ".iso"
for ISOLINUX).

=head1 SEE ALSO

http://sourceforge.net/apps/mediawiki/leaf/index.php?title=Bering-uClibc_4.x_-_Developer_Guide_-_Building_an_Image

=cut

# vi: set ai sw=4 wm=5 fo=cql:
