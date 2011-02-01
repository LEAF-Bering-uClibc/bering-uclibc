
#$Id: PackageList.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
# class for doing the make source stuff

package buildtool::Make::PackageList;

use strict;
use Carp;

use vars qw(@ISA);

@ISA = qw(buildtool::Make::Source);

##############################################################################
sub _getType() {
    return "list";
}


########################################################################################
##
sub _makeCompleteList($) {
    my $self = shift;
    my $type = $self->_getType();
    my @list ;
    my @dep;
    my $part;
    $self->debug("starting for type $type");

    if (@_) {
	@list = @_;
    } else {
	# we habe nothing to do, so return!
	$self->debug("list is empty, returning");
	return ();
    }

	my $p_l_dllist = [];
    #my @dllist = ();

    foreach $part (@list) {
	# now get the list of required sources/packages:

	@dep = $self->getRequireList($part);
	# have a look if we already have done this in the past



	foreach my $deppack (@dep) {
		$self->debug("$deppack added to complete list list");
		push @{$p_l_dllist}, $deppack;
	}
	# now look at the list, if the force switch is given we want to
	# source the packages/sources we got from the commandline,
	# so add them if needed
	      if ($self->isInList($part,@{$p_l_dllist}) == 0) {
		    push @{$p_l_dllist}, $part;
		}
  }

  my $p_l_downloadList = [];
  my $p_h_packages = {};

  # Remove duplicates from the required-list
  foreach my $package (@{$p_l_dllist}) {
    next if exists($p_h_packages->{$package});
    $p_h_packages->{$package} = 1;

    push(@{$p_l_downloadList},$package);
  }

  return @{$p_l_downloadList};
}



##############################################################################
sub make () {
    my $self = shift ;
    my @list = ();
	if (@_) {
	  @list = @_;
	} else {
	  # create our own list!
	  @list = $self->_getNameList("all");
	  $self->debug("creating new list");
	}


    my @dllist = $self->_makeCompleteList(@list);

    print join(",",@dllist) . "\n";

    # hopefully everything was ok
    return 1;

}



1;
