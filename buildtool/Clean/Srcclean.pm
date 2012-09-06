
package buildtool::Clean::Srcclean;

use strict;
use Carp;

use parent qw< buildtool::Clean::Buildclean >;

###############################################################################
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

    # Read the package config
    my %pkg_config = $self->_readBtConfig($pkg);

    # Populate the envstring from file section of package config
    my $envstring  = $self->_makeEnvString( %{ $pkg_config{'file'} } );

    # now call make srcclean
    $self->_callMake("srcclean", $pkg, $envstring);

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
