# $Id: Http.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $


package buildtool::DownloadTypes::Http;

use strict;
use Carp;
use File::Spec;
use buildtool::DownloadTypes::Wget;

use vars qw(@ISA $VERSION);

$VERSION	= '0.3';
@ISA		= qw(buildtool::DownloadTypes::Wget);


sub new($$)
{
  my %params = (dir => "");
  my $type;

  ($type, %params) = @_;

  my $self = $type->SUPER::new(%params);


  # initialization , not done by new();
  $self->_initialize(%params);

  return($self);
}

sub _initialize($$) {
  my ($self, %params) = @_;

  $self->debug("http::initialize called");

  # first check the params
##  $self->_checkParams(%params);

  # use wget initialize:
  $self->SUPER::_initialize(%params);

  $self->{'PROTOCOL'} ='http://';
}

# the rest is identical to Wget



1;
