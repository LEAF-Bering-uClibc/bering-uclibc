# $Id: Clean.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
# This file is the base to be used for clean functions.
#

package buildtool::Clean;

use buildtool::Common::InstalledFile;
use buildtool::Clean::Buildclean;
use buildtool::Clean::Remove;
use buildtool::Clean::Distclean;
use buildtool::Clean::Srcclean;
use Config::General 2.15;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Common::InstalledFile);


###############################################################################
# remove the package file list
sub _removeFile() {
  my $self = shift;
  my $file = shift || return;

  my $ret = system("rm", "-f", "$file");
  if ($ret != 0) {
    $self->debug("removing $file failed:$! ");
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

  my $ret = system("rmdir", "$dir");
  if ($ret != 0) {
    $self->debug("removing $dir failed:$! ");
    return 0;
  } else {
    $self->debug("dir $dir removed");
    return 1;
  }
}

##########################################################################
# force remove of dir
sub _forceRemoveDir() {
  my $self = shift;
  my $dir = shift || return;

  my $ret = system("rm", "-rf", "$dir");
  if ($ret != 0) {
    $self->debug("force mode removing $dir failed:$! ");
    return 0;
  } else {
    $self->debug("dir $dir removed in force mode");
    return 1;
  }
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
    die("removing directory $dir failed:") unless $self->_removeDir($dir);
  }

}



# END OF FILE
1;
