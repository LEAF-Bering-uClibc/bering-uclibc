# $Id: CvsExt.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
package buildtool::DownloadTypes::CvsExt;

use buildtool::DownloadTypes::CvsPserver;

use vars qw(@ISA $VERSION);

$VERSION        = '0.1';
@ISA            = qw(buildtool::DownloadTypes::CvsPserver);

######################################################
# construct the cvsroot from username and ...
sub _mkCvsRoot ($) {
      my $self = shift;
      # check cvsroot
      if (! ($self->{'CVSROOT'} =~ /^\/.*$/)) {
	  $self->{'CVSROOT'} = "/" . $self->{'CVSROOT'};
      }
      my $root = ":ext:" . $self->{'USERNAME'} . "\@". $self->{'SERVER'} . ":" . $self->stripSlashes($self->{'CVSROOT'});
      $self->debug("my root: " .$root);
      return $root;

}

