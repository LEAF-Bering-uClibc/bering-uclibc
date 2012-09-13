# This file is the base to be used for clean functions.
#

package buildtool::Clean;

use strict;
use Carp;

use Config::General 2.15;
use File::Path qw< remove_tree >;

use buildtool::Common::InstalledFile;
use buildtool::Clean::Buildclean;
use buildtool::Clean::Remove;
use buildtool::Clean::Distclean;
use buildtool::Clean::Srcclean;

use parent qw< buildtool::Common::InstalledFile >;

###############################################################################
# remove the package file list
sub _removeFile() {
    my $self = shift;
    my $file = shift || return;

    my $ret = unlink "$file";
    if ( $ret <= 0 ) {
        $self->debug("removing $file failed:$!");
        return 0;
    } else {
        $self->debug("file $file removed");
        return 1;
    }
}

##########################################################################
# remove the package file list
sub _removeDir() {
    my $self = shift;
    my $dir = shift || return;

    if ( -d $dir ) {
        my $ret = rmdir "$dir";
        if (! $ret) {
            $self->debug("removing $dir failed:$!");
            return 0;
        }
        $self->debug("dir $dir removed");
    }
    return 1;
}

##########################################################################
# force remove of dir
sub _forceRemoveDir() {
    my $self = shift;
    my $dir = shift || return;

    if ( -d $dir ) {
        remove_tree( $dir, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $dir, $message ) = %$diag;
                if ( $dir eq '' ) {
                    $self->debug("error:$message");
                } else {
                    $self->debug("force mode removing$dir failed:$message");
                }
            }
            return 0;
        }
        $self->debug("dir $dir removed in force mode");
    }
    return 1;
}

###############################################################################
# remove the files of a package
sub _removeFiles () {
  my $self = shift;
  my @filelist = @_;
  my $dirlist = [];
  foreach my $file (@filelist) {
    if (-d $file && ! -l $file) {
      push(@{$dirlist}, $file)
    } else {
      die("removing file $file failed:") unless $self->_removeFile($file);
    }
  }

  # reverse sort the dirlist by length - that way, we delete the child dirs
  # before trying to delete the parents
  foreach my $dir (sort { length($b) <=> length($a)} @{$dirlist}) {
    die("removing directory $dir failed!") unless $self->_removeDir($dir);
  }

}

# END OF FILE
1;
