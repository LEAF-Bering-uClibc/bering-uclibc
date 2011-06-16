#$Id: Srcclean.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $

package buildtool::Clean::Srcclean;

use buildtool::Clean;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Clean::Buildclean);

###############################################################################
sub callMakeClean () {
  my $self = shift;
  my $pkg = shift || confess "no pkg given!";
  my $path = $self->_getSourceDir($pkg);

  my %globConf = %{$self->{'CONFIG'}}; 

  $self->SUPER::callMakeClean($pkg);

  print "calling 'make srcclean' for $pkg: ";
  # check if dir exists, if not, it is o.k.
  $self->dumpIt(\%globConf,0);
  if (! -d $path) {
	$self->debug("$path is not there, might be ok");
  } else {

	system("make -d -C ".$path. " -f ./".$globConf{'buildtool_makefile'}." srcclean MASTERMAKEFILE=".$globConf{'root_dir'}. "/make/MasterInclude.mk". " BT_BUILDROOT=". $globConf{'root_dir'}. " >>".$globConf{'logfile'}. " 2>&1" ) == 0
	  or die "make clean ". $self->make_text_red("failed")." for ".$path."/".$globConf{'buildtool_makefile'}." , please have a look at the logfile " . $globConf{'logfile'};
  }
  $self->print_ok();
  print "\n";
  return 1
}

sub clean () {
  my $self = shift;
  my $pkg ;
  my @list;

  if (@_) {
    @list = @_ ;
  } else {
    # get a list of all pkg/sources that are installed:
    @list = $self->getEntries("build");
  }

  foreach $pkg (@list) {
    # first have a look if already deleted:
    # if yes, do nothing!
    if (! $self->searchInstalled4Pkg("source", $pkg)) {
      $self->debug("$pkg is not in source list, maybe already cleaned!\n");
      if (!$self->{'CONFIG'}{'force'}) {
        # force is not enabled, so continue with next one
        next;
      } else {
        $self->debug("force enabled, trying to remove anyway");
      }
    }
    # first call make clean for the package buildtool.mk itself
    $self->callMakeClean($pkg);

    # now remove everything from our list:
    $self->_removePackageFiles($pkg);
    # remove the list
    $self->_removePackageListFile($pkg);

    # remove the pkg name from the list of build files:
    $self->deleteEntry("build", $pkg);
    $self->deleteEntry("source", $pkg);
    $self->writeToFile();

  }
}
1;
