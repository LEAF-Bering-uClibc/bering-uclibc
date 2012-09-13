# Tools library for uclibc-bering
# (C) 2012 Yves Blusseau
# This software is distributed under the GNU General Public Licence,
# please see the file COPYING

package buildtool::Tools;

use strict;
use warnings;

use Exporter ();
use Carp;
use File::Path qw< make_path remove_tree >;

use vars qw< @ISA @EXPORT_OK %EXPORT_TAGS >;

BEGIN {
    @ISA       = qw{ Exporter };
    @EXPORT_OK = qw{
      create_dir remove_dir expand_variables
      };
    %EXPORT_TAGS = ( ALL => \@EXPORT_OK, );
}

##################################################################
# create directory if not exists
sub create_dir {
    my ($dirname) = @_;
    if ( ! -d $dirname ) {
        # create the dir
        make_path( $dirname, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $dir, $message ) = %$diag;
                if ( $dir eq '' ) {
                    croak "error: $message\n";
                } else {
                    croak "can't create directory '$dir': $message\n";
                }
            }
        }
    }
}

##################################################################
# remove directory and subdirectories
sub remove_dir {
    my ($dirname) = @_;
    if ( -d "$dirname" ) {
        # create the dir
        remove_tree( $dirname, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $dir, $message ) = %$diag;
                if ( $dir eq '' ) {
                    croak "error: $message\n";
                } else {
                    croak "can't remove directory '$dir': $message\n";
                }
            }
        }
    }
}

########################################################
# expand variables from scalar pass in the first argument
# use %ENV and hash ref pass in the second arguments to
# resolv variables to values
sub expand_variables {
    my ( $string, $hash ) = @_;

    croak "First argument must be defined" if not defined $string;

    # expand variables
    while ( $string =~ /\$(\w+)\b/ ) {
        my $value;
        if ( exists $ENV{ uc($1) } ) {    # Get the value from %ENV
            $value = $ENV{ uc($1) };
        } elsif ( exists $hash->{ lc($1) } ) {    # Get the value from hash
            $value = $hash->{ lc($1) };
        } else {
            die "Error: can't expand variable \$$1\n";
        }
        $string =~ s/\$$1\b/$value/g;
    }
    return $string;
}


1;
