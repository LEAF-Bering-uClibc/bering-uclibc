# remove everything that is part of a package
# the installed files and the unpacked and downloaded sources

package buildtool::Clean::Distclean;

use strict;
use Carp;

use parent qw< buildtool::Common::Object >;

sub clean () {

    my $self = shift;
    $self->debug("starting");

    # remove the dirs in here...
    my @dirs = @{ $self->{'CONFIG'}{'buildenv_dir'} };
    foreach my $dir (@dirs) {
        my $dir1 = $self->absoluteFilename($dir);
        print "removing $dir1 recursive ";
        if ( system("rm -rf $dir1") != 0 ) {
            my $err = "" . $!;
            $self->die( "removing $dir1 failed", $err );
        }
        $self->print_ok();
        print "\n";
    }

    # remove the installed packages file
    my $listfile =
      $self->absoluteFilename( $self->{'CONFIG'}{'installedfile'} );

    # read in the file if it exists
    if ( -e $listfile ) {
        system("rm -f $listfile") == 0
          or die "removing $listfile failed: " . $!;
    }

    # now at last remove the directory for the installedfiles
    confess("buildtracedir not set in global config!")
      if (   !$self->{'CONFIG'}{'buildtracedir'}
           or $self->{'CONFIG'}{'buildtracedir'} eq "" );

    system( "rm", "-rf", $self->{'CONFIG'}{'buildtracedir'} ) == 0
      or
      $self->die( "removing " . $self->{'CONFIG'}{'buildtracedir'} . "failed: ",
                  "" . $! );
}

1;

