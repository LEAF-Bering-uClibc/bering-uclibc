# $Id: buildtool.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
# functions for buildtool2 for uclibc-bering
# (C) 2003 Arne Bernin
# (C) 2012 Yves Blusseau
# This software is distributed under the GNU General Public Licence,
# please see the file COPYING

@EXPORT = qw(debug logme);


use vars  qw(@EXPORT);



#############################################################################
# example:
# server :http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi


use strict;

use File::Spec::Functions qw(:ALL);
use File::Path qw(make_path);

use buildtool::Download;
use buildtool::Common::InstalledFile;
use buildtool::Common::Object;

use vars  ('%globConf');


######################################################################
# a debug routine for later purposes...
#
sub debug {
  if ($globConf{'debugtoconsole'}) {
    print join("",@_) . "\n" ;
  }
  if ($globConf{'debugtologfile'}) {
    open LOGFILE , ">> $globConf{'logfile'}";
    print LOGFILE join("",@_) . "\n" ;
  }
}

######################################################################
# print something to the logfile
#
sub logme {
    if ( $globConf{'debugtologfile'} ) {
        my $logfile = $globConf{'logfile'};
        # open log
        open LOGFILE, ">> $logfile"
          or die "cannot open logfile '$logfile'";
        print LOGFILE join( "", @_ ) . "\n";
    }
}


##################################################################
# make the log directory if needed

sub log_dir_make {
    my $logfile = $globConf{'logfile'};
    # Get the dirname:
    my ($volume, $directory, $file) = splitpath( $logfile );
    my $dirname = File::Spec->catdir( $volume, $directory );
    if ( ! -d $dirname ) {
        # create the dir
        make_path( $dirname, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $dir, $message ) = %$diag;
                if ( $dir eq '' ) {
                    die "error: $message\n";
                } else {
                    die "can't create directory '$dir': $message\n";
                }
            }
        }
    }
}

########################################################
# adds the buildroot path to a given path if path is not
# absolute
sub make_absolute_path {
  my $path = shift;
  $path = strip_slashes($path);
  if ($path =~ /^\//) {
    # starts with slash so absolute
    return $path;
  }
  # else
  return strip_slashes($globConf{'root_dir'} . "/" . $path);
}

################################################
# checks the build environment (dirs and...)
sub check_env {
      logme("checking build environment");
  debug("setting \$GNU_TARGET_NAME to toolchain name ($globConf{'toolchain'})");
  $ENV{GNU_TARGET_NAME} = $globConf{'toolchain'};
  my @dirs = @{$globConf{'buildenv_dir'}};
  foreach my $dir (@dirs) {
    my $dir1 = strip_slashes(make_absolute_path($dir));
    if (! -d $dir1) {
      debug("making directory $dir1");
      system("mkdir -p $dir1") == 0
	or die "makedir $dir1 failed! " . $!;
    } elsif (! -w $dir1) {
	die "cannot write to dir $dir1";
      }
    }
  #check_lib_link();

  # check if we should trace:
  if($globConf{'usetracing'}) {
  	# disable it until it is found in the path:
    	$globConf{'usetracing'} = 0;
   	 # try to load tracer
	eval "use buildtool::Common::FileTrace";
        if ($@) {
                die("loading  buildtool::Common::FileTrace failed!", "if you want to use file tracing support install File::Find");
          }

    	$globConf{'usetracing'} = 1;		
    	logme("enabling file tracing support");
   } else {
    logme("trace support not enabled in configfile");
  }
}

# checks if the link from /lib/ld-uclibc.so to stagingdir/lib exists
sub check_lib_link {
      my $linktarget;
      my $linkdest = make_absolute_path("staging/lib/ld-uClibc.so.0");
      logme("checking link /lib/ld-uClibc.so");
      if ($linktarget=readlink("/lib/ld-uClibc.so.0")) {
	    # check if pointing to right location
	    if ($linktarget eq $linkdest) {
		  return 1;
	    }
      }
      # else
      print "\n\n" .buildtool::Common::Object::make_text_red('','Warning:');
      print "The symlink from /lib/ld-uClibc.so.0 --> $linkdest does not exist, this may cause problems with some configure scripts that try to run a compiled program\n\nShould i create this link for you (Y/n)?";
      my $ask = <STDIN>;
      chop $ask;
      if ($ask eq "" or $ask eq "y" or $ask eq "Y" or $ask eq "j" or $ask eq "J" ) {
	    print "please enter root ";
	    if (system("su -c \"ln -f -s $linkdest /lib/ld-uClibc.so.0 \"") != 0) {
		  die "cannot create symlink";
	    }
	    
      } 
      return 1;
}


####################################################
# print a colored o.k.
sub print_ok {
  # just print a colored o.k.
  print buildtool::Common::Object::make_text_green('','[0.K.]');
}

####################################################
# print a colored failed
sub print_failed {
  # just print a colored failed
  print buildtool::Common::Object::make_text_red('','[FAILED]');
}


#############################################################################
# strip all unneaded double slashes from an url,
# but leave the starting :// alone...

sub strip_slashes {
  my $string = shift || "";

  $string =~ s,//,/,g ;
  # put in the *tp:// back again:
  $string =~ s,^([a-zA-Z]+tp:)/(.*)$,$1//$2,;

  return $string;
}

1;
