
#$Id: Build.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
# class for doing the make source stuff

package buildtool::Make::Build;

use strict;
use Carp;

use vars qw(@ISA);

@ISA = qw(buildtool::Make::Source);

##############################################################################
sub _getType() {
    return "build";
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

    ################################ make the download list #################

    print "make the list of required build packages: ";

    my @dllist = $self->_makeCompleteList(@list);

    print join(",",@dllist) . " ";

    # do we have to download anything ??
    if (scalar @dllist == 0) {
	  # no, so just return
	  print("nothing to do ");
	  $self->print_ok();
	  print "\n";
	  return ;

    }

    $self->print_ok();
    print "\n";




    #######################################
    # now call buildFiles for everything here:
    $self->_buildFiles(@dllist);

    # hopefully everything was ok
    return 1;

}


sub _buildFiles($) {
    my $self = shift;
    my @dllist = ();
    my $part;
    my $download;
    my %server;
    my $tracer;
    
    if (@_) {
	@dllist = @_;
    } else {
	# we habe nothing to do, so return!
	$self->debug("download list list is empty, returning!");
	return 0;
    }

    ############################################download files ##################################
    # start to look at everything

    foreach $part (@dllist) {
	# the download function wants two hashes: one for the files,
	# and one for the servers (that's the easy part) ;-)
	%server = %{$self->{'FILECONF'}->{'server'}};

	print "\nbuild source/package: $part\n" ;
	print "------------------------\n";

	my %flconfig = $self->_readBtConfig($part);

	# make the environment vars ready:
	# those vars can be set in the buildtool.cfg via a env = NAME entry
	# this would result in NAME=$filename entry
	my $envstring = "";
	if ($self->{'CONFIG'}->{'usetracing'}) {
		$self->debug("trace support enabled, using it");
		$tracer = buildtool::Common::FileTrace->new($self->{'CONFIG'}, (part => $part));
        }
	# make the envstring
	$envstring = $self->_makeEnvString(%{$flconfig{'file'}});

	
	# now call make build
	$self->_callMake("build", $part, $envstring);
	# add to list
	$self->addEntry("build",$part);
	# write to installed list
	$self->writeToFile();
        # search for changed files
	if ($self->{'CONFIG'}->{'usetracing'}) {

		$tracer->getFileList();
		$tracer->writeToFile();
	}
  }
}







1;
