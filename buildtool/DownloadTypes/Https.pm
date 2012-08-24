# Bering-uClibc 5.x
# Copyright (C) 2012 Yves Blusseau

package buildtool::DownloadTypes::Https;

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

  $self->debug("https::initialize called");

  # first check the params
##  $self->_checkParams(%params);

  # use wget initialize:
  $self->SUPER::_initialize(%params);

  $self->{'PROTOCOL'} ='https://';
}

# the rest is identical to Wget

1;
