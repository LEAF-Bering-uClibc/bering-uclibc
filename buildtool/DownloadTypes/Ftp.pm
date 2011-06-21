# $Id: Ftp.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $


package buildtool::DownloadTypes::Ftp;

use strict;
use Carp;
use File::Spec;
use buildtool::DownloadTypes::Wget;


use vars qw(@ISA $VERSION);

@ISA = qw(buildtool::DownloadTypes::Wget);
$VERSION	= '0.3';



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

  $self->debug("ftp::initialize called");

  # first check the params
  $self->_checkParams(%params);

  # use wget initialize:
  $self->SUPER::_initialize(%params);

  $self->{'PROTOCOL'} ='ftp://';
}

# the rest is identical to Wget


1;
