#! /usr/bin/perl -w

# main program buildtool2 for uclibc-bering
# Copyright (C) 2003 Arne Bernin
# Changes for Bering-uClibc 5.x Copyright (C) 2012 David M Brooke & Yves Blusseau
# This software is distributed under the GNU General Public Licence,
# please see the file COPYING

use FindBin qw($Bin);       # where was script installed?
use lib $FindBin::Bin;      # use that dir for libs, too

use File::Spec::Functions qw(:ALL);

use buildtool::buildtool;
use buildtool::Tools qw(:ALL);
use buildtool::Clean;
use buildtool::Make::Tar;
use buildtool::Make::Source;
use buildtool::Make::Build;
use buildtool::Make::Headers;
use buildtool::Make::PackageList;
use buildtool::Config;
use Config::General qw(ParseConfig);
use strict;

use vars ('%globConf');;

$::VERSION = '0.7';

our $baseDir = rel2abs($FindBin::Bin);

################################################################################
BEGIN {
      my $lockfile = catfile( $FindBin::Bin, 'conf', 'lockfile');
      # check for lockfile:
      if (-f $lockfile){
	    die("\nIt seems you are already running another instance of buildtool, please wait until it finished!\n".
		"if this is not true, please remove the $lockfile file yourself\n\n");
      }
      # else touch lockfile
      die("making lockfile failed:".$!) if (system("touch $lockfile") != 0);
};

END {
    my $errvar = $?;
    my $lockfile = catfile( $FindBin::Bin, 'conf', 'lockfile' );
    # whatever happens, remove lockfile
    unlink $lockfile or die("removing lockfile '$lockfile' failed: $!");
    exit($errvar);
}

sub usage {
print <<MYEOF
usage: $0 [option] command [pkgname|srcname] [...]

commands:
describe [pkgname|srcname]\t shows descriptionlines of package
list [sourced|built]\t\t shows a list of built/sourced packages and sources
dumpenv [pkgname|srcname]\t dump the environment of buildtool and package
source [pkgname|srcname]  \t downloads, unpacks and patches
                          \t the wanted package/source
build [pkgname|srcname]     \t the same as source, but builds
                              \t and installs sources/packages also
pkglist [pkgname|srcname]  \t create a list with all dependencies
                          \t for the package given or all if no name given
buildclean [pkgname|srcname]\t removes everything that is outside
                             \t the source dir
srcclean [pkgname|srcname]\t same as buildclean + call make srcclean
remove [pkgname|srcname]\t same as buildclean + remove everything from dldir
distclean                  \t remove everything
maketar                    \t make a tar for distribution

options:
-v                         \t just print version and exit
-f                         \t allows you to force the command even if the internal
                           \t state of buildtool states it has nothing to do
-O                         \t Do not override default Server entries with the ones
                           \t found in package/source buildtool config
-D                         \t Download nothing, use files in Source dir (useful for devel)		
-d                         \t Only to be used in conjunction with the "source" target. 
                           \t Only download files, don't invoke the source action on buildtool.mk
-t toolchain               \t Build using the specified toolchain
                           \t (or actually build that toolchain if srcname = "toolchain")
                           \t Value of "toolchain" is e.g. i486-unknown-linux-uclibc
MYEOF
;
exit(1);
}

# ' <- fix emacs fontification

sub load_global_configfile {
    my ($global_config_file) = @_;
    return
      Config::General::ParseConfig(
        "-ConfigFile" => make_absolute_path( $global_config_file, $baseDir ),
        '-IncludeRelative' => 1,
        '-IncludeGlob'     => 1,
        "-LowerCaseNames"  => 1
                                  );
}


################################################################################
my %force_config = ();

&usage() if ($#ARGV < 0);

# check the 
while ( $ARGV[0] and $ARGV[0] =~ /^-.*/ ) {
    my $option = $ARGV[0];
    $option =~ s/^-(.*)$/$1/;
    shift;
    # now switch according to option:
    if ($option eq "v" or $option eq "-version") {
        print "Version: $::VERSION" . "\n";
        exit (0);
    } elsif ($option eq "h" or $option eq "-help") {
        &usage();
    } elsif ($option eq "f") {
        $force_config{'force'} = 1;
    } elsif ($option eq "D") {
        $force_config{'nodownload'} = 1;
    } elsif ($option eq "O") {
        $force_config{'noserveroverride'} = 1;
    } elsif ($option eq "d") {
        $force_config{'downloadonly'} = 1;
    } elsif ($option eq "t") {
        $force_config{'toolchain'} = $ARGV[0];
        shift;
    } else {
        print buildtool::Common::Object::make_text_red('',"Error:" ) . " Unknown Option -" . $option . "\n\n";
        exit(1);
    }
}

# load buildtool.conf and buildtool.local configurations
%globConf = readBtGlobalConfig(
    ConfigFile  => catfile( $baseDir, 'conf', 'buildtool.conf' ),
    ForceConfig => {
        %force_config,
        'root_dir' => $baseDir,    # inject root_dir
                   }
);

# make sure, log dir is there
create_dir( make_absolute_path( $globConf{'log_dir'}, $baseDir ) );

# make the logfile absolute
$globConf{'logfile'} = make_absolute_path( $globConf{'logfile'}, $baseDir );

# set kernel version
my $kver = qx(BT_BUILDROOT=$baseDir GNU_TARGET_NAME=$globConf{'toolchain'} make -s -f $baseDir/make/MasterInclude.mk kversion);
my $kbranch = qx(BT_BUILDROOT=$baseDir GNU_TARGET_NAME=$globConf{'toolchain'} make -s -f $baseDir/make/MasterInclude.mk kbranch);
chomp $kver;
chomp $kbranch;
die "Can't determine kernel version!"
  unless $kver =~ /^\d+\.\d+/ && $kbranch =~ /^\d+\.\d+/;

$globConf{'kernel_branch'} = $kbranch;
$globConf{'kernel_version'} = $kver;

# read in global file-config
my %sourcesConfig;
eval {
    %sourcesConfig = load_global_configfile( $globConf{globalconffile} );
}
or do {
    my $path = $@;
    die $@,$/ if $path =~ /\*/; # Don't try to create a file with a wildcard in is name
    $path =~ s,^.*\"([^\"]*)\".*not exist.*ConfigPath: ([^!]*)!.*\n,$2/$1,;
    print STDERR "Created missing file \"$path\"...\n";
    open TFILE, ">", $path or die "Can't create file \"$path\"!";
    close TFILE;
    %sourcesConfig = load_global_configfile( $globConf{globalconffile} );
};

# now it seems we are really starting, lets put a message in
# the logfile , logdir should be created by check_env
logme( \%globConf, "==================================================" );
logme( \%globConf, "buildtool Version " . $::VERSION . " starting" );
logme( \%globConf, scalar localtime );

# Set and check the environment
check_env( \%globConf );

#???
# put in the default config stuff
my $configClass = buildtool::Config->new(\%globConf, \%sourcesConfig);
$configClass->adjustFileConfig();

# now search for real commands:
if ($ARGV[0] eq "describe") {
  # show descriptions
  shift;
  $configClass->showDescription(@ARGV);
} elsif ($ARGV[0] eq "list") {
  # show descriptions
  shift;
  my $list = buildtool::Common::InstalledFile->new(\%globConf);
  my $what = exists $ARGV[0] ? $ARGV[0] : 'all';
  if ($what eq 'all') {
      $list->showList();
  } elsif ($what eq 'sourced') {
      $list->showSourcedList();
  } elsif ($what eq 'built') {
      $list->showBuiltList();
  } else {
      print STDERR "\nunknown parameter '" . $ARGV[0] . "' for the list command!\n\n";
      usage();
  }
} elsif ($ARGV[0] eq "source") {
  # source packages/sources
  shift;

  my $make = buildtool::Make::Source->new(\%globConf, \%sourcesConfig);
  $make->make(@ARGV);

} elsif ($ARGV[0] eq "pkglist") {
  # just print packagelist (useful fpr other tools)
  shift;
  my $make = buildtool::Make::PackageList->new(\%globConf, \%sourcesConfig);
  $make->make(@ARGV);

} elsif ($ARGV[0] eq "build") {
  # build packages/sources
  shift;
  # first do a make source:
  #check_lib_link();

  my $source = buildtool::Make::Source->new(\%globConf, \%sourcesConfig);
  $source->make(@ARGV);
  # now do a make build...
  my $make= buildtool::Make::Build->new(\%globConf, \%sourcesConfig);
  $make->make(@ARGV);

} elsif ($ARGV[0] eq "headers") {
  # make platform headers from packages/sources
  shift;
  my $make= buildtool::Make::Headers->new(\%globConf, \%sourcesConfig);
  $make->make(@ARGV);

} elsif ($ARGV[0] eq "buildclean") {
  # buildclean package/source
  shift;
  my $clean = buildtool::Clean::Buildclean->new(\%globConf, \%sourcesConfig);
  $clean->clean(@ARGV);
} elsif ($ARGV[0] eq "srcclean") {
  # srcclean package/source
  shift;
  my $clean = buildtool::Clean::Srcclean->new(\%globConf, \%sourcesConfig);
  $clean->clean(@ARGV);

} elsif ($ARGV[0] eq "remove") {
  # remove package/source
  shift;
  my $clean = buildtool::Clean::Remove->new(\%globConf, \%sourcesConfig);
  $clean->clean(@ARGV);

} elsif ($ARGV[0] eq "maketar") {
  # make a tar file
  my $make = buildtool::Make::Tar->new(\%globConf);
  $make->make();

} elsif ($ARGV[0] eq "distclean") {
  # make it distclean
  print "\nAre you sure you want to delete everything you've downloaded and built? (y/N) ";
  my $ask = <STDIN>;
  chop $ask;
  if ($ask eq "y" or $ask eq "Y" or $ask eq "j" or $ask eq "J") {
    print "making distclean:\n" ;
    my $clean = buildtool::Clean::Distclean->new(\%globConf);
    $clean->clean();
  }

} elsif ($ARGV[0] eq "dumpenv") {
  shift;
  my $env = buildtool::Make::Source->new(\%globConf, \%sourcesConfig);
  $env->dump_env( package => $ARGV[0], xoutput => '/tmp/toto' );

} else {
  # unknown command
  print "\nunknown command " . $ARGV[0] . "!\n\n";
  usage();
}

