
# $Header: /cvsroot/leaf/src/bering-uclibc4/buildtool/buildtool/DownloadTypes/ViewCVS.pm,v 1.3 2010/10/16 19:48:11 nitr0man Exp $
# cleaneup done


package buildtool::DownloadTypes::ViewCVS;

use strict;
use Carp;
use File::Spec;
use buildtool::DownloadTypes::Wget;


use vars qw(@ISA $VERSION);

$VERSION	= '0.3';
@ISA		= qw(buildtool::DownloadTypes::Wget);

sub new($$)
{

  my %params = ( revision => "0.0.0.0",
		   dir => "");

  my $type = "";

  ($type, %params) = @_;


  my $self = $type->SUPER::new(%params);


  # initialization , not done by new();
  $self->_initialize(%params);

  ##
  $self->{'REVISION'}	= $params{'revision'};

  return($self);
}

sub _initialize($$) {
  my ($self, %params) = @_;

  $self->debug("ViewCVS::initialize called");

  # first check the params
  $self->_checkParams(%params);

  # use wget initialize:
  $self->SUPER::_initialize(%params);
  $self->{'WGET_CONTINUE'} = 0;
  $self->{'USE_ATTIC'} = 0;

}
sub _checkParams ($$) {
  my ($self, %params) = @_;
  $self->SUPER::_checkParams(%params);

  # check for revision addionaly
  confess($params{'revision'} . " is not a valid revision") if (!(exists($params{'revision'}) and ($params{'revision'} =~ /[0-9\.]+/) or $params{'revision'} eq "HEAD")) ;
}


sub _getURL($;$) {

  my ($self, $from_attic) = @_;

  my $attic = '';
  $attic = '/Attic' if ($self->{'USE_ATTIC'});

  return $self->stripSlashes('http://' .
			     $self->{'SERVER'} .
			     '/viewvc/' .
			     $self->{'SERVERPATH'} .
			     '/' . $self->{'DIR'} .
			     $attic .
			     '/' . $self->{'FILENAME'} .
			     '?revision=' . $self->{'REVISION'} );# .
#			     '&content-type=application/octet-stream') ;

}

sub download($) {
  my ($self) = @_;

  my $useAttic = 0;
  my $url;
  my $log = $self->getLogfile();

  while (1) {

    # use download from wget...
    if ($self->SUPER::download() != 1) {
      # download failed,
      # try the Attic version:
      # changed for viewcvs >= 0.8
      $self->{'USE_ATTIC'} = 1;
      $self->debug("file was removed from cvs, trying it from attic");
    }


    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks) = stat($self->{'FULLPATH'});

    if (!$size or $size==0) {
      $self->die("wget failed", $self->{'FULLPATH'}.' could not be found');
    }


    # now we have downloaded something, check if this is an html page
    # and if so, throw an error cause something has gone wrong...
    my $fh = Symbol::gensym();
    my $line;

    open($fh, '< ' . $self->{'FULLPATH'});
    $line = <$fh>;
    close $fh;


    if ($line and ($line =~ /^<!doctype html/)) {
      # something went wrong, we only got an html page, that's
      # not what we want i suppose
      # maybe it was just removed, so search for a FILE REMOVED in the output:
      if (!$useAttic && system("grep -q 'FILE REMOVED' " . $self->{'FULLPATH'}) >>8 == 0) {
        #retry with Attic
        $self->{'USE_ATTIC'} = 1;
        $self->debug("file was removed from cvs, getting it from attic");
        # remove file
        unlink($self->{'FULLPATH'});
        next;

      } else {
        $self->die("wget failed", $self->{'FULLPATH'}.' seems to be an viewcvs error message and not the file we wanted to download');
      }
    }

    # if we get here, this means everything went ok
    last;
  }
  return 1;
}



1;
