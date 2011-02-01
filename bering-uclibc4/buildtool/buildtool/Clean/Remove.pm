#$Id: Remove.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $

# remove everything that is part of a package
# the installed files and the unpacked and downloaded sources

package buildtool::Clean::Remove;

use buildtool::Clean::Buildclean;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Clean::Buildclean);


sub clean () {
  my $self = shift;
  my @list;
  if (@_) {
    @list = @_ ;
  } else {
    # get a list of all pkg/sources that are installed:
    @list = $self->getEntries("source");
  }
  print "removing: ". join(",",@list) . " ";
  # first of all, call Buildclean clean for this :
  $self->SUPER::clean(@list);

  foreach my $pkg (@list) {
    # after that remove the source dir
    my $dir = $self->_getSourceDir($pkg);
    $self->_forceRemoveDir($dir);
    # now get it out of the list of installed source packages:
    $self->deleteEntry("source", $pkg);
    $self->writeToFile();

  }


  $self->printOk() ;
  print "\n";
}
  
1;
