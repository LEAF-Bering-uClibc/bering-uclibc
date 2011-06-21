# $Id: CvsPserver.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
package buildtool::DownloadTypes::CvsPserver;

sub BEGIN { 
      push @VCS::LibCVS::Authentication_Functions, \&myAuthentication;
      
}

# global hash for authentication...
$buildtool::DownloadTypes::CvsPserver::Auth_Values = {};

######################################################
# authentication function used by libcvs code
# will be called for authentication...

sub myAuthentication {
 my ($scheme, $needed, $info) = @_;
 return if ($scheme ne "pserver");
 my %ret = ("scrambled_password" => "A");
 # get the cvsroot from info 
 my $root = $info->{CVSRoot}->as_string();

 # try to get our password from global hash
 # workaround... i know...
 if (exists $buildtool::DownloadTypes::CvsPserver::Auth_Values->{$root} and  $buildtool::DownloadTypes::CvsPserver::Auth_Values->{$root} ne "") {
       %ret = ("scrambled_password" => $buildtool::DownloadTypes::CvsPserver::Auth_Values->{$root});
 }

# use Data::Dumper;
# my $dumper = Data::Dumper->new([$info]);
# $dumper->Indent(1);
# print STDERR  $dumper->Dumpxs(), "\n";

 return \%ret;
}


use strict;
use Carp;
use File::Spec;
use buildtool::Common::Object;
use Data::Dumper;
use VCS::LibCVS;

use vars qw(@ISA $VERSION);

$VERSION        = '0.1';
@ISA            = qw(buildtool::Common::Object);


######################################################

sub new($$)
{
  my ($type, %params) = @_;
  # make new object ourself, don't call super!

  my $self = $type->SUPER::new($params{'config'}, %params);

  return($self);
}

######################################################
# check parameters given to constructor
sub _checkParams ($$) {
	my ($self, %params) = @_;

  
	## note: don't check for dir, this is optional and could be null
  
	# check if we have everything in here we need
	foreach my $name ("config", "dlroot", "server", "serverpath", "filename", "cvsroot") {
		confess($self->makeTextRed("Error in config:") . " in section server:". $params{'server'}. " $name not defined\n\n") if (! $params{$name} or ($params{$name} eq "")); 
  }
                   
  return 1;
}

######################################################
# scramble password for pserver authentication
sub scramble($$) {
      my $self = shift;
      my @shifts= (0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
		   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
		   114,120, 53, 79, 96,109, 72,108, 70, 64, 76, 67,116, 74, 68, 87,
		   111, 52, 75,119, 49, 34, 82, 81, 95, 65,112, 86,118,110,122,105,
		   41, 57, 83, 43, 46,102, 40, 89, 38,103, 45, 50, 42,123, 91, 35,
		   125, 55, 54, 66,124,126, 59, 47, 92, 71,115, 78, 88,107,106, 56,
		   36,121,117,104,101,100, 69, 73, 99, 63, 94, 93, 39, 37, 61, 48,  
		   58,113, 32, 90, 44, 98, 60, 51, 33, 97, 62, 77, 84, 80, 85,223,
		   225,216,187,166,229,189,222,188,141,249,148,200,184,136,248,190,
		   199,170,181,204,138,232,218,183,255,234,220,247,213,203,226,193,
		   174,172,228,252,217,201,131,230,197,211,145,238,161,179,160,212,
		   207,221,254,173,202,146,224,151,140,196,205,130,135,133,143,246,
		   192,159,244,239,185,168,215,144,139,165,180,157,147,186,214,176,
		   227,231,219,169,175,156,206,198,129,164,150,210,154,177,134,127,
		   182,128,158,208,162,132,167,209,149,241,153,251,237,236,171,195,
		   243,233,253,240,194,250,191,155,142,137,245,235,163,242,178,152 );
      my $string = shift;
      my $retstring = "A";
      #my $a = 0;
      for (my $a = 0; $a < length($string) ; $a++) {
	    my $char = substr($string, $a, 1);
	    $retstring .= chr($shifts[ord($char)]);
      }
      $self->debug($retstring);
      return $retstring;

}


######################################################
# internal initialize
sub _initialize ($$) {
  my ($self, %params) = @_; 
  $self->_checkParams(%params); 

  $self->{'SERVER'}     = $params{'server'};
  $self->{'DLROOT'}     = $params{'dlroot'};
  $self->{'SERVERPATH'} = $params{'serverpath'};
  $self->{'FILENAME'}   = $params{'filename'};
  $self->{'DIR'}        = $params{'dir'}; 
  $self->{'REVISION'}   = $params{'revision'} || "HEAD";
  
  $self->{'CVSROOT'} = $params{'cvsroot'};
  
  if ($params{'username'} and $params{'username'} ne "") {
	$self->{'USERNAME'}   = $params{'username'} ;
  } else {
	$self->{'USERNAME'} = "anonymous";
  }
  $self->{'DEBUG'} = 1;
  $self->debug(Dumper({%params}));
  $self->debug("username:". $self->{'USERNAME'});


  if ($params{'password'} and $params{'password'} ne "") {
	$self->{'PASSWORD'}   = $self->scramble($params{'password'});
  } else {
	$self->{'PASSWORD'} = $self->scramble("");
  }
  $self->{'FULLPATH'} = $self->stripSlashes(File::Spec->catfile($self->{'DLROOT'}, $self->{'FILENAME'}));

  # should we use continue of dowloads (aka -c):
  $self->{'WGET_CONTINUE'} = 1;

  # add cvsroot to global array
  $buildtool::DownloadTypes::CvsPserver::Auth_Values->{$self->_mkCvsRoot} = $self->{'PASSWORD'};
}


######################################################
# construct the cvsroot from username and ...
sub _mkCvsRoot ($) {
      my $self = shift;
      # check cvsroot
      if (! ($self->{'CVSROOT'} =~ /^\/.*$/)) {
	  $self->{'CVSROOT'} = "/" . $self->{'CVSROOT'};
      }
      my $root = ":pserver:" . $self->{'USERNAME'} . "\@". $self->{'SERVER'} . ":" . $self->stripSlashes($self->{'CVSROOT'});
      $self->debug("my root: " .$root);
      return $root;

}

######################################################
# this function is called by global Download

sub download  {
	my $self = shift;
	my $log = $self->getLogfile();
	my $reproot = VCS::LibCVS::Datum::Root->new($self->_mkCvsRoot());
      
	my $repo = VCS::LibCVS::Repository->new($reproot);
	my $filename = "";
	# check if OverwriteFiles is disabled, if so,
	# do NOT overwrite 
	if ( ! $self->overwriteFileOk($self->{'FULLPATH'})) {
		# just log what we don't do
		$self->logme("not overwriting file ". $self->{'FULLPATH'}  ." as requested");
		} else {
		# add serverpath only if it is given
		if ($self->{'SERVERPATH'} and $self->{'SERVERPATH'} ne "") {
		$filename .= $self->{'SERVERPATH'} . "/";
		}
		
		if ($self->{'DIR'} and $self->{'DIR'} ne "") {
		$filename .= $self->{'DIR'} . "/";
		}
		$filename .= $self->{'FILENAME'};
		$self->stripSlashes($filename);
		#remove leading / if there
		$filename =~ s/^\///;
		$self->debug("filename:" . $filename);
		my $file = VCS::LibCVS::RepositoryFile->new($repo, $filename );
	
		my $sticky;
	
		if ($self->{'REVISION'} =~ /^[0-9.]+$/) {
		$sticky = VCS::LibCVS::StickyRevision->new($repo, $self->{'REVISION'});
		} else {
		$sticky = VCS::LibCVS::StickyTag->new($repo, $self->{'REVISION'});
		}
	
		my $revision = $file->get_revision($sticky);
		# get everything from server
		my $contents = $revision->get_contents();
	
		open TARGET, "> ". $self->{'FULLPATH'} or confess ("cannot open file ". $self->{'FULLPATH'}  .  "for writing   " );
		# write buffer to file
		print TARGET $contents->as_string();
		close TARGET;
	}
}

1;
