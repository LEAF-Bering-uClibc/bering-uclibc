# remove everything that is part of a package
# the installed files and the unpacked and downloaded sources

package buildtool::Clean::Distclean;

use strict;
use Carp;

use buildtool::Tools qw< remove_dir expand_variables >;

use parent qw< buildtool::Common::Object >;

sub clean () {

    my $self = shift;
    $self->debug("starting");

    # remove the dirs in here...
    my @dirs = @{ $self->{'CONFIG'}{'buildenv_dir'} };
    foreach my $dir (@dirs) {
        if ($dir) {
            my $dir1 = $self->absoluteFilename(
                                  expand_variables( $dir, $self->{'CONFIG'} ) );
            print "removing $dir1 recursive ";
            remove_dir($dir1);
            $self->print_ok();
            print "\n";
        }
    }

    # remove the installed packages file
    my $listfile =
      $self->absoluteFilename( $self->{'CONFIG'}{'installedfile'} );

    # read in the file if it exists
    if ( -e $listfile ) {
        unlink $listfile or die "removing $listfile failed: " . $!;
    }

    # now at last remove the directory for the installedfiles
    confess("buildtracedir not set in global config!")
      if (   !$self->{'CONFIG'}{'buildtracedir'}
           or $self->{'CONFIG'}{'buildtracedir'} eq "" );

    remove_dir(
                $self->absoluteFilename(
                           expand_variables(
                                             $self->{'CONFIG'}{'buildtracedir'},
                                             $self->{'CONFIG'}
                                           )
                                       )
              );
}

1;
