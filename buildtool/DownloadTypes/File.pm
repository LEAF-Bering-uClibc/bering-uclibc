# $Id: File.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $


package buildtool::DownloadTypes::File;

# "download type" that allows to copy a file locally
# sample buildtool.cfg:
#
#
#<Server local>
#	Type = file
#	serverpath = ../linux
#</Server>
#
#
#<File linux-2.4.20.tar.bz2>
#	Server = local
#	dlpath = .
#</File>
#
# if this is for the package "kerneltest" this means:
# the file $BT_ROOT/source/linux/linux-2.4.20.tar.bz2
# will be copied to
# the file $BT_ROOT/source/kerneltest/linux-2.4.20.tar.bz2


use strict;
use Carp;
use File::Spec;
use buildtool::Common::Object;

use vars qw(@ISA $VERSION);
@ISA		= qw(buildtool::Common::Object);


sub new($$)
{
	my ($type,
		%params) = @_;


	foreach my $name ("config", "serverpath", "filename") {

		if (!(exists($params{$name}) && $params{$name})) {

			confess ("no " . $name . " given");
		}
	}

	my $self = $type->SUPER::new(\%{$params{'config'}}, %params);

	$self->_initialize(%params);

	return($self);
}

sub _initialize($$) {
      my ($self, %params) = @_;
      $self->debug("starting");

#      $self->SUPER::_initialize(%params);
#      use Data::Dumper;
#      my $dumper = Data::Dumper->new([$self, \%params]);
#      my $dumper = Data::Dumper->new([\%params]);
#      $dumper->Indent(1);
#      print STDERR  $dumper->Dumpxs(), "\n";
      
      
      $self->debug("buildtool::DownloadTyped::File _initialize called");
      $self->{'DLPATH'}	= ".";
      $self->{'PATH'}         = $params{'serverpath'};
      $self->{'PATH'} .= "/" .$params{'dir'} if ($params{'dir'} and $params{'dir'} ne "") ;
      $self->{'FILENAME'}	= $params{'filename'};
      $self->{'SOURCEFILE'}   = $self->stripSlashes(
						    File::Spec->catfile(
									$self->{'PATH'},
									$self->{'FILENAME'}));

      $self->{'FULLPATH'}     = $self->stripSlashes(
						    File::Spec->catfile(	$params{'dlroot'},
										$self->{'DLPATH'},
										$self->{'FILENAME'}));
}



sub download($) {
      my ($self) = @_;
      # first check if file exists, else set error and return
      if (! -f $self->{'SOURCEFILE'}) {
	    my $msg = "file ". $self->{'SOURCEFILE'} . " does not exist";
	    $self->debug($msg);
	    $self->_setErrorMsg($msg);
	    return 0;
      }
      
      my $cp = ['cp', $self->{'SOURCEFILE'}, $self->{'FULLPATH'} ];
      if (!	$self->overwriteFileOk($self->{'FULLPATH'}) ) { #$self->{'CONFIG'}->{'overwritefiles'} and -e $self->{'FULLPATH'}) {
	    # just log what we don't do
	    $self->logme("not overwriting file ". $self->{'FULLPATH'}  ." as requested");
	} else {
	      $self->debug("calling cp with:" . join(" ", @{$cp}));
	      if ((system (@{$cp})>>8) != 0) {
		    my $msg= "cp failed: " . join(" ", @{$cp});
		    $self->debug($msg);
		    $self->_setErrorMsg($msg);
		    return 0;
		    
	      }
	}
      
      # give back true return code
      return 1;
      
      
}


1;
