#$Id: Tar.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $


package buildtool::Make::Tar;

use buildtool::Common::Object;
use buildtool::Clean::Distclean;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Common::Object);



###################################################
# make a tar file to distribute this
sub make () {
  my $self = shift;

  # first make a distclean
  print "calling distclean first\n";
  my $clean = buildtool::Clean::Distclean->new($self->{'CONFIG'});
  $clean->clean();

  print "make tar archive";
  # get our version
  my $version = $self->{'CONFIG'}{'version'};
  #

  # tar it
  system ("cd .. && tar cvzhf buildtool-$version.tgz buildtool/") == 0
    or die "taring failed";
  $self->print_ok();
  print "\n";
  print "filename is ../buildtool-$version.tgz\n";
  return 1;
}

# this is perl ... ;-)
1;
