# $Id: Common.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
package buildtool::Make::Common;

use buildtool::Common::InstalledFile;
use Config::General;
use strict;
use Carp;

use vars qw(@ISA $ENV);

@ISA = qw(buildtool::Common::InstalledFile);


##############################################################################
sub _initialize () {
  my $self = shift;

  # call super initialize
  $self->SUPER::_initialize();

  ################################### class configuration BEGIN ################
  # add stuff to environment:
  $self->{'ENVIRONMENT'} = "LANG=C";
  # set debug value of this Class
  $self->{'DEBUG'} = 1;
}


