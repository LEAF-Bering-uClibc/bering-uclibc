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
use Carp;

use File::Spec::Functions qw(:ALL);

use buildtool::Tools qw(:ALL);
use buildtool::Download;
use buildtool::Common::InstalledFile;
use buildtool::Common::Object;

use vars  ('%globConf');

# checks if the link from /lib/ld-uclibc.so to stagingdir/lib exists
sub check_lib_link {
    my $linktarget;
    my $linkdest =
      make_absolute_path( "staging/lib/ld-uClibc.so.0", $globConf{'root_dir'} );
    logme("checking link /lib/ld-uClibc.so");
    if ( $linktarget = readlink("/lib/ld-uClibc.so.0") ) {
        # check if pointing to right location
        if ( $linktarget eq $linkdest ) {
            return 1;
        }
    }

    # else
    print "\n\n" . buildtool::Common::Object::make_text_red( '', 'Warning:' );
    print
      "The symlink from /lib/ld-uClibc.so.0 --> $linkdest does not exist, this may cause problems with some configure scripts that try to run a compiled program\n\nShould i create this link for you (Y/n)?";
    my $ask = <STDIN>;
    chop $ask;
    if (    $ask eq ""
         or $ask eq "y"
         or $ask eq "Y"
         or $ask eq "j"
         or $ask eq "J" ) {
        print "please enter root ";
        if ( system("su -c \"ln -f -s $linkdest /lib/ld-uClibc.so.0 \"") != 0 )
        {
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
