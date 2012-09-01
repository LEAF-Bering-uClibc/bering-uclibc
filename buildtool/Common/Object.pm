# $Id: Object.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $


package buildtool::Common::Object;

use strict;
use Carp;
use File::Spec;
use File::Path;


use vars qw($VERSION);

$VERSION	= '0.5';


######################################################################
# constructor routine
#

sub new($$)
{
	my ($type, $p_h_config, %rest) = @_;

	my $self;

	confess("Config is not a valid hash, is a ". ref($p_h_config)) if (ref($p_h_config) ne "HASH") ;

	$self= {
		'CONFIG'		=> $p_h_config,
	};


	bless($self, $type);

	$self->dumpIt(\%rest);



#	if (scalar(keys(%rest)) > 0) {
	      # call init function if we have something to init
	      $self->_initialize(%rest);
#	}
	return($self);
}


######################################################################
# init function
#
sub _initialize() {
  my $self = shift;
  # empty function,
  # fill if needed
  ######################################### default init #############
  # set debug value of Class (for debugging output)
  $self->{'DEBUG'} = $self->{'CONFIG'}->{'debugtoconsole'} ||$self->{'CONFIG'}->{'debugtologfile'} ;
  ######################################### default init END##########


}


######################################################################
# strip double slashes in paths
#

sub stripSlashes($$) {
	my ($self,$str) = @_;

	# remove all double slashes, unless they're part of the protocol section of an url
	$str =~ s,(?<!tp:)//,/,g;

	return ($str);
}


######################################################################
# get logfilename
#

sub getLogfile($) {
	my ($self) = @_;
	return $self->absoluteFilename($self->{'CONFIG'}->{'logfile'});
}


######################################################################
# convert relative to absolute path
#

sub absoluteFilename($$) {
	my ($self, $path) = @_;

	$path = $self->stripSlashes($path);

	if (!File::Spec->file_name_is_absolute($path)) {
		$path = File::Spec->catfile($self->{'CONFIG'}->{'root_dir'},$path);
	}

	# if the file is still not an absolute filename, try adding the root dir
	if (!File::Spec->file_name_is_absolute($path)) {
		$path = File::Spec->catfile(File::Spec->rootdir(),$path);
	}

    return $path;
}

######################################################################
# a debug routine for later purposes...
#
sub debug {
  my $self = shift;
  #	no strict 'refs';

  my $caller = (caller(1))[3];

  if ( $self->{'CONFIG'}->{'debugtoconsole'} && $self->{'DEBUG'}) {
    print "$caller:";
    print join("",@_) . "\n" ;
  }

  if ($self->{'CONFIG'}->{'debugtologfile'} && $self->{'DEBUG'}) {
     my $fh = Symbol::gensym();

    open($fh, '>> ' . $self->getLogfile());
    print $fh "$caller:";
    print $fh join("",@_) . "\n" ;
		close $fh;
  }

}
######################################################################
# print something to the logfile
#
sub logme {
	my $self = shift;

	if ($self->{'CONFIG'}->{'debugtologfile'}) {
		my $fh = Symbol::gensym();

		open($fh, '>> ' . $self->getLogfile()) or die "cannot open logfile" . $self->getLogfile();
		print $fh join("",@_) . "\n" ;
		close $fh;


  	}
}

####################################################
# just gives the text back in red
sub make_text_red($$) {
	my ($self,$text) = @_;

	# not very smart...but looks nice...
	return "\e[1;31m$text\e[0;39m";
}

####################################################
# just gives the text back in red
sub makeTextRed($$) {
	my ($self,$text) = @_;

	# not very smart...but looks nice...
	return "\e[1;31m$text\e[0;39m";
}

####################################################
# just gives the text back in yellow
sub make_text_yellow($$) {
	my ($self,$text) = @_;

	# not very smart...but looks nice...
	return "\e[1;33m$text\e[0;39m";
}

####################################################
# just gives the test back in green
sub make_text_green($$) {
	my ($self,$text) = @_;

	# not very smart...but looks nice...
	return "\e[1;32m$text\e[0;39m";
}

####################################################
# print a colored o.k.
sub printOk($) {
	my ($self) = @_;
	# just print a colored o.k.
	print $self->make_text_green("[0.K.]");
}

	    sub print_ok($) {
	      my ($self) = @_;
	      $self->printOk();
	    }

####################################################
# print a colored failed
sub print_failed($) {
	my ($self) = @_;
	# just print a colored failed
	print $self->make_text_red("[FAILED]");
}

#############################################################################
# strip all unneaded double slashes from an url,
# but leave the starting :// alone...

sub strip_slashes {
  my $self = shift;
  my $string = shift || "";

  $string =~ s,//,/,g ;
  # put in the *tp:// back again:
  $string =~ s,^([a-zA-Z]+tp:)/(.*)$,$1//$2,;

  return $string;
}


######################################################################
# check if file exists and size is > 0
#

sub fileExists {
  my ($self, $filename) = @_;
  confess "no filename given " if (!$filename or $filename eq "");

  if ((-e $filename) and (-s $filename > 0)) {
    return 1;
  }
  # else
  return 0;
}


#################################################
# returns the position of the given item in array
sub getArrayPosition {
  my $self = shift;
  my $item = shift || "";
  my @arr = @_;

#  $self->debug("starting, item=$item");
  my $a = 0;
  for ($a = 0; $a < scalar(@arr); $a++) {
    if ($arr[$a] eq $item) {
      return $a;
    }
  }
  # else return -1
  return -1;
}

#######################################################################################
# delete the entry $del from the list completly
sub delFromArray ($$$) {
  my $self = shift;
  my $del = shift;
  my @list = @_;
  my $pos;
  $self->debug("starting");
  $pos = $self->getArrayPosition($del, @list);
#  $self->debug("pos:$pos");
  while (($pos = $self->getArrayPosition($del, @list)) >= 0) {
    $self->debug("splicing $del at $pos ");
    splice @list, $pos, 1;
  }


  return @list;

}

######################################################################
# searches if entry is in given list
sub isInList {
      my ($self, $searchfor, @list) = @_;
      foreach my $item (@list) {
	    if ($searchfor eq $item) {
		  return 1;
	    }
      }
	    # else
      return 0;
}


######################################################################
# checks if the given file exists and is > 0 and if overwriteFiles
# is set in the config

sub overwriteFileOk {
  my ($self, $filename) = @_;
  confess "no filename given " if (!$filename or $filename eq "");

  if ((! $self->{'CONFIG'}->{'OverwriteFiles'} ) and $self->fileExists($filename)) {
    # don't overwrite the file !
    $self->debug("should not overwrite $filename as OverwriteFiles is not set in config");
    return 0;
  }
  # else
  return 1;
}

######################################################################
# just print everything for now.
sub print ($$) {
      print join(" ",$@);
}

######################################################################
# get the internal error message from an object
sub getErrorMsg ($) {
      my $self = shift;
      return $self->{'ERRORMSG'} if ($self->{'ERRORMSG'});
      # else
      return "";
}

######################################################################
# set the internal error message from an object
sub _setErrorMsg ($) {
      my ($self,$msg) = @_;
      $self->{'ERRORMSG'} = $msg;
      return 1;
}




######################################################################
# dump everything we have to the debug channel
# just a dirty hack...
sub dumpIt {
      my $self = shift;
      my $ref = shift || ();

      my $count = shift || 0;

      use Data::Dumper;
      my $dumper = Data::Dumper->new([$ref]);
      $dumper->Indent(1);

      $self->debug($dumper->Dumpxs() . "\n");

}

sub protectSlashes {
      my ($self, $string) = @_;
      $string =~ s/\//\\\//g;
      return $string;
}


sub die {
      my ($self, $prefix, $msg) = @_;
      my $pmsg = "";
      # start with an \n to empty the stdout buffer
      print "\n";

      if ($msg eq "") {
	    $msg = $prefix;
	    $prefix = "";
      }
      if ($prefix ne "") {
	    $pmsg = $self->makeTextRed($prefix . ": ") ;
	    $pmsg .= $msg;
      } else {
	$pmsg = $self->makeTextRed($msg) ;
	}
      $pmsg .= "\nyou might find useful information in log/buildtoollog\n\n";
      die($pmsg);

}


1;
