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
use Getopt::Long qw< :config no_auto_abbrev no_ignore_case bundling >;
use Date::Format;
use File::Spec;
use File::Temp;
use File::Copy;
use Pod::Usage;
use Carp;
use FindBin qw($Bin);       # where was script installed?
use lib $FindBin::Bin;      # use that dir for libs, too

use buildtool::Tools
  qw< make_absolute_path create_dir remove_dir readBtGlobalConfig readBtConfig >;

my $imgName = "Bering-uClibc";

my %configHash = ( );
my $image;
my $tmpDir;

sub createTempDir;
sub cleanTempDir;
sub system_exec;
sub createDirUnlessItExists;
sub copyFilesToTempDir;
sub copyFilesWithSearchAndReplace;

my %options = (
    'verbose' => 0,
    'debug'   => 0,
);

# Process command line arguments
GetOptions(
    \%options, qw{
      help|h!  verbose|v!  debug|d!  keep-tmp|k!  toolchain|t=s  release|r=s
      kernel-arch|a=s  image-type|i=s variant|v=s
      }
) or pod2usage(2);
pod2usage(-verbose => 2)  if ($options{help});

# Check for kernel-arch parameter
pod2usage( -exitval => 2, -message => "$0: no kernel architecture given.\n" )
  unless exists $options{'kernel-arch'};
my $kernelArch = lc $options{'kernel-arch'};

# Check for image-type parameter
pod2usage( -exitval => 2, -message => "$0: no image type given.\n" )
  unless exists $options{'image-type'};
my $imgType = lc $options{'image-type'};

# Check for variant parameter
pod2usage( -exitval => 2, -message => "$0: no variant given.\n" )
  unless exists $options{'variant'};
my $variant = lc $options{'variant'};

my $verbose = $options{'verbose'};
my $debug   = $options{'debug'};
my $relver  = $options{'release'};
my $keeptmp = $options{'keep-tmp'};

$SIG{'INT'} = 'CLEANUP';

my $baseDir	= File::Spec->rel2abs($FindBin::Bin);

# Check we are running as (fake)root
warn "WARNING: Not running as (fake)root" if ( $> != 0 );

# Fetch the buildtool config
my $buildtoolconf = File::Spec->catfile( $baseDir, 'conf', 'buildtool.conf' );
my $forceConfig = {
    'root_dir' => $baseDir,    # inject root_dir
};
$forceConfig->{'toolchain'} = $options{toolchain} if exists $options{toolchain};

my %btConfig = readBtGlobalConfig(
    ConfigFile  => $buildtoolconf,
    ForceConfig => $forceConfig,
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

# Fetch the image template config file aka
# ${conf_dir}/image/templates/buildimage.cfg
my %imConfig = readBtConfig(
    "ConfigFile" => File::Spec->catfile(
        $btConfig{'conf_dir'}, 'image',
        'templates',           $btConfig{'buildimage_config'}
    ),
    "DefaultConfig" => \%btConfig,
    "ForceConfig"   => {
        'ImageType'  => $imgType,
        'KernelArch' => $kernelArch,
        'Variant'    => $variant,
    },
    "IncludedFileMustExists" => 1,
);

# Generate date label
$configHash{ '{DATE}' } = time2str( "%Y-%m-%d", time );
print "Build Date is:\t\t$configHash{ '{DATE}' }\n" if $verbose;

print "Image name:\t\t$imgName\n"     if $verbose;
print "Kernel Arch:\t\t$kernelArch\n" if $verbose;
print "Image type:\t\t$imgType\n"     if $verbose;
print "Variant:\t\t$variant\n"        if $verbose;

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
my $modTgzPath = $imConfig{ 'modtgzpath' };
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
my $imageStruc = $imConfig{'image'};
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
my $fileBase =
  File::Spec->catfile( $btConfig{'image_dir'}, $image,
    join( '_', $imgName, $relver, $kernelArch, $imgType, $variant ) );

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

print "Temporary directory:\t$tmpDir\n" if $keeptmp;

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
    my $absSource = make_absolute_path( $source, $baseDir );
    my $absTarget = File::Spec->catdir( $tmpDir,  $target );

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
    my $absSource = make_absolute_path( $source, $baseDir );
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

B<buildimage.pl> [-h] [-v] [-k] [--toolchain=<toolchain>]
              [--release=<relver>] --kernel-arch=<karch> --image-type=<imgtype>
              --variant=<variant>

=head1 DESCRIPTION

B<buildimage.pl> creates a Bering-uClibc disk image.

The disk image can be for I<SYSLINUX> (suitable for writing to a flash drive),
I<PXELINUX> (suitable for network booting) or can use I<ISOLINUX>.
The choice between these is specified by the B<--image-type> command-line
argument.

For I<SYSLINUX> and I<PXELINUX>, the "image" is a .tar.gz file which needs to be
extracted onto suitably prepared media or installed on a I<PXELINUX> server.
For I<ISOLINUX> the "image" is a .iso file which can be burned to a CD-R disk.

The generated image name is formed from:
   - "Bering-uClibc"
   - The value of the B<--release> command-line argument
       Something like "5.0-beta1"
   - The value of the B<--kernel-arch> command-line argument
       Something like "i686"
   - The value of the B<--image-type> command-line argument
       Something like "syslinux"
   - The value of the B<--variant> command-line argument
       Something like "vga"

Each of these is separated by an underscore character (_).
In addition, a file extension based on ImageType is appended (e.g. ".iso"
for ISOLINUX).
Disk images are create into the B<image> directory.

=head1 OPTIONS

=over

=item B<-h>, B<--help>

Prints this manual page.

=item B<-v>, B<--verbose>

Produce verbose output.

=item B<-k>, B<--keep-tmp>

Do not delete temporary directory.

=item B<-t> <toolchain>, B<--toolchain>=<toolchain>

Specify the toolchain to use. By default toolchain defined in conf/buildtool.conf is used.

=item B<-r> <relver>, B<--release>=<relver>

String to append to image name to show release version (e.g. 5.0beta1). By default use version defined in initrd package.

=item B<-a> <karch>, B<--kernel-arch>=<karch>

Kernel architecture to put in the image.

=item B<-i> <imgtype>, B<--image-type>=<imgtype>

Type of bootloader to use. Currently only I<isolinux> and I<syslinux> is supported.

=item B<-v> <variant>, B<--variant>=<variant>

Variant to use. Currently only I<vga> and I<serial> is defined.

=back

=head1 SEE ALSO

http://sourceforge.net/apps/mediawiki/leaf/index.php?title=Bering-uClibc_5.x_-_Developer_Guide_-_Building_an_Image

=cut

# vi: set ai sw=4 wm=5 fo=cql:
