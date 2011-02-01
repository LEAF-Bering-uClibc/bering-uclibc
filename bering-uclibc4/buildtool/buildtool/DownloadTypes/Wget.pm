# $Id: Wget.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $


package buildtool::DownloadTypes::Wget;

use strict;
use Carp;
use File::Spec;
use buildtool::Common::Object;


use vars qw(@ISA $VERSION);

@ISA		= qw(buildtool::Common::Object);

sub new($$)
{
  my ($type, %params) = @_;
  # make new object ourself, don't call super!

  my $self = $type->SUPER::new($params{'config'}, %params);

  return($self);
}


sub _checkParams ($$) {
  my ($self, %params) = @_;
#  $self->dumpIt(\@_);

  ## note: don't check for dir, this is optional and could be null
  # check if we have everything in here we need
  foreach my $name ("config", "dlroot", "server", "serverpath", "filename") {
    confess ("no " . $name . " given") unless exists($params{$name}) && $params{$name};
  }

  return 1;
}


sub _getURL($) {
  my ($self) = @_;

  return $self->stripSlashes($self->{'PROTOCOL'} .
			     $self->{'SERVER'} .
			     "/" . $self->{'SERVERPATH'} .
			     '/' . $self->{'DIR'} .
			     '/' . $self->{'FILENAME'});

}


sub _initialize ($$) {
  my ($self, %params) = @_; 

  $self->{'SERVER'}	= $params{'server'};
  $self->{'DLROOT'}     = $params{'dlroot'};
  $self->{'SERVERPATH'} = $params{'serverpath'};
  $self->{'FILENAME'}	= $params{'filename'};
  $self->{'DIR'} 	= $params{'dir'};
  $self->{'FULLPATH'} = $self->stripSlashes(File::Spec->catfile($self->{'DLROOT'}, $self->{'FILENAME'}));

  # should we use continue of dowloads (aka -c):
  $self->{'WGET_CONTINUE'} = 1;

}


sub download($) {
      my ($self) = @_;
      
      # build url
      my $url =$self->_getURL();
      
      my $log = $self->getLogfile();
      my @wget = ("wget", "-O", $self->{'FULLPATH'}, "-a", $log);
      # check if we want the -c flag to be set
      if ($self->{'WGET_CONTINUE'}) {
	    push @wget, "-c";
      }
      if ($self->{'CONFIG'}->{'wget_options'} and ($self->{'CONFIG'}->{'wget_options'} ne "")) {
	foreach my $opt (split /\s+/, $self->{'CONFIG'}->{'wget_options'}) {
          push @wget, $opt;
	}
      }
      # add url
      push @wget, $url;
      # check if we should overwrite,
      # note that wget itsels might fail, if we edit a file
      # and it gets smaller, wget will try to download it again 
      if ( ! $self->overwriteFileOk($self->{'FULLPATH'})) {
	    # just log what we don't do
	    $self->logme("not overwriting file ". $self->{'FULLPATH'}  ." as requested");
      } else {
	    # download and let wget handle this
	    $self->debug("calling wget with:" . join(" ", @wget));
	    if ((system (@wget)>>8) != 0) {
		  $self->_setErrorMsg("wget failed with: " . $! . " used:" . join(" ", @wget));
		  return 0;
	    }
	    
      }
      
      # if we get here, everything went ok
      return 1;
}




1;
