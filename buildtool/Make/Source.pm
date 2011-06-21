# $Id: Source.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
package buildtool::Make::Source;

use buildtool::Common::InstalledFile;
use Config::General qw(ParseConfig);
use strict;
use Carp;

use vars qw(@ISA $ENV);

@ISA = qw(buildtool::Common::InstalledFile);

sub new($$$$) {
  # my new function
  my $type = shift || confess("no Type given");
  my $globConf = shift || confess("no globConf given");
  my $fileConf = shift || confess("no fileConf given");

  my $self = $type->SUPER::new($globConf);

  # add fileconf to myself
  $self->{'FILECONF'} = $fileConf;
  # don't use _initialize here!
  # it is called by the super::new.
$self->{'DEBUG'} = 1;
  return $self;
}

##############################################################################
sub _initialize () {
  my $self = shift;

  # call super initialize
  $self->SUPER::_initialize();

  ################################### class configuration BEGIN ################
  # add stuff to environment:
  $self->{'ENVIRONMENT'} = "LANG=C";
  # how deep do we go before throwing an error ??
  $self->{'REQUIRELIST_MAXDEPTH'} = 20;
  # <--- done in the parent class!!!
  # set debug value of this Class
  #$self->{'DEBUG'} = 1;
  #<----
  ################################### class configuration END ################
  $self->{'REQUIRELIST'} = ();
  # don't need itrace here
  $self->{'ITRACE'} = "";

}


##############################################################################
## returns list of all source or package names

sub _getNameList($$) {
  my $self = shift;
  my $type = shift;
  if ($type eq "package" or $type eq "source") {
    return keys %{$self->{'FILECONF'}{$type}};
  }
  if ($type eq "all") {
    return (keys %{$self->{'FILECONF'}{'source'}}, keys %{$self->{'FILECONF'}{'package'}});
  }
  # else
  confess("unknown type $type");
}


##############################################################
# just a wrapper...
# just make sure that the requirelist is empty!
sub getRequireList ($$) {
      my $self = shift;
      # get package or return empty list if empty package...
      my $package = shift || return ();
      # reset internal list
      $self->{'REQUIRELIST'} = [];

      # start it:
      $self->_getRequireList($package);

      return @{$self->{'REQUIRELIST'}};
}

##############################################################
# real get Require list function :
# internal function, don't call from outside
sub _getRequireList($$;$) {
      my ($self, $package, @mycalls) = @_;


      $self->debug("starting with arg: $package");

      my @reqlist ;

      # get the config (all packages and source alltogether):
      my %pkgs = $self->_getAllHash();


      die("something is wrong in make_require_list, $package is not a package nor a source") if (! exists($pkgs{$package}));

      # now look if we were already called before in the callist (to prevent loops!)
      if ($self->isInList($package, @mycalls)) {
	    $self->debug("we are already in the call list, something wrong, loop in config ???");
	    return;
      }


      # look if we are already in the list, if so, move us in front of the list...

      if ($self->isInList($package, @{$self->{'REQUIRELIST'}})) {
	    $self->debug("$package is already in list, moving it forward");
	    # delete ourself from the list
	    @{$self->{'REQUIRELIST'}} = $self->delFromArray($package,@{$self->{'REQUIRELIST'}});
      }

      # add ourself to the 'global' requirelist:
      @{$self->{'REQUIRELIST'}} = ($package, @{$self->{'REQUIRELIST'}});

      # check for requirements

      if (exists($pkgs{$package}{'requires'}) && (ref($pkgs{$package}{'requires'}{'name'}) eq 'ARRAY')) {
	    @reqlist = @{$pkgs{$package}{'requires'}{'name'}};
      } elsif ($pkgs{$package}{'requires'}{'name'}) {
	    @reqlist = ($pkgs{$package}{'requires'}{'name'});
      } else {
	    # nothing to go deeper, so set the current level.
	    $self->debug("no requirements for $package");
      }



      foreach my $part (@reqlist) {
	    next unless defined($part) && $part;
	    $self->debug("part:$part");
	    #next if $self->isInList($package, @{$self->{'REQUIRELIST'}});
	    # if not:
	    $self->_getRequireList($part, @mycalls, $package);
	    }

      # no real return value...
      return 1;
}

#######################################################################
# returns a hash with all packages and sources together (no need to
# do a $cfg->{'package'} anymore...
sub _getAllHash ($) {
   my $self = shift;
   my %newhash = (%{$self->{'FILECONF'}->{'package'}},%{$self->{'FILECONF'}->{'source'}});
   return %newhash;
}


#######################################################################
# make the things for the source command, actual this means
# downloading and patching or whatever the makefile wants...
# args: cfg (hashref) ref to config
# @list (@_) names for packages/sources

sub make {
	my $self = shift ;
	my @list = ();
	if (@_) {
	  @list = @_;
	} else {
	  # create our own list!
	  @list = $self->_getNameList("all");
	  $self->debug("creating new list");
	}

	################################ make the download list #################

	print "make the list of required source packages: ";

	my @dllist = $self->_makeCompleteList(@list);

	print join(",",@dllist) . " ";


	# do we have to download anything ??
	if (scalar @dllist == 0) {
	      # no, so just return
	      print("nothing to do ");
	      $self->print_ok();
	      print "\n";
	      return ;

	}

	$self->print_ok();
	print "\n";


	#######################################
	# call download Files to do the rest
	$self->downloadFiles(@dllist);


	return 1;
}

########################################################################################
##

sub downloadFiles($) {
    my $self = shift;
    my @dllist = ();
##    my $cfg = $self->{'FILECONF'};
    my $part;
    my $download;
    my %server;


    if (@_) {
	@dllist = @_;
    } else {
	# we habe nothing to do, so return!
	$self->debug("download list list is empty, returning!");
	return 0;
    }

    ############################################download files ##################################
    # start to download everything we need:

    foreach $part (@dllist) {
	# the download function wants two hashes: one for the files,
	# and one for the servers (that's the easy part) ;-)
	%server = %{$self->{'FILECONF'}->{'server'}};

	print "\nsource/package: $part\n" ;
	print "------------------------\n";

	# download buildtool.cfg only if we are in source mode,
	# if build this should already happened
	$self->_downloadBuildtoolCfg($part);
	## read in config:
	my %flconfig = $self->_readBtConfig($part);

	# now download the complete list of files:
	$download = buildtool::Download->new($self->{'CONFIG'});
	$download->setServer($flconfig{'server'});
	$download->setFiles($flconfig{'file'});
	$download->setDlroot($self->_getSourceDir($part));
	$download->download();

	# make the environment vars ready:
	# those vars can be set in the buildtool.cfg via a env = NAME entry
	# this would result in NAME=$filename entry
	my $envstring = "";
	# make the envstring
	$envstring = $self->_makeEnvString(%{$flconfig{'file'}});
	my $downloadOnly = 0;
	$downloadOnly = 1 if exists($self->{'CONFIG'}{'downloadonly'}) && $self->{'CONFIG'}{'downloadonly'};

	if (!$downloadOnly) {
		# now call make source
		$self->_callMake("source", $part, $envstring);
		# add to list
		$self->addEntry("source",$part);
		$self->writeToFile();
	}


  }
}

########################################################################################
sub _readBtConfig ($$) {
      my $self = shift;
      my $pkgname = shift || confess("no filename given");

      my $configFile = $self->absoluteFilename($self->{'CONFIG'}{'source_dir'}."/". $pkgname . "/". $self->{'CONFIG'}{'buildtool_config'});
	# now make a recursive download of all the files in there
      my %flconfig = Config::General::ParseConfig("-ConfigFile" => $configFile, "-LowerCaseNames" => 1);

      %flconfig = $self->_addDefaultServer(%flconfig);
      return %flconfig;
}
########################################################################################
sub _downloadBuildtoolCfg ($$$) {
    my $self = shift;
    my $part = shift;
    my $mdir;
    my %allfiles = $self->_getAllHash();
    my %server = %{$self->{'FILECONF'}->{'server'}};

    if (exists $allfiles{$part}{'directory'}) {
	$mdir = $allfiles{$part}{'directory'};
    } else {
	$mdir = "";
    }

    # download the buildtool config gile

    my %files = ( $self->{'CONFIG'}{'buildtool_config'} => {'revision' => $allfiles{$part}{'revision'},
							  'server' 		=> $allfiles{$part}{'server'},
							  'directory' 	=> $mdir
							 }
		);

    # first get the config file we want:

    my $download = buildtool::Download->new($self->{'CONFIG'});
    $download->setServer(\%server);
    $download->setFiles(\%files);
    $download->setDlroot($self->_getSourceDir($part));
    $download->download();


}






########################################################################################
##
sub _addDefaultServer ($$) {
    my $self = shift;
    my %flconfig = @_;
    my $key ;

    if($self->{'CONFIG'}->{'noserveroverride'}) {
	$self->debug("Override package config servers is enabled!");
    }
    ##############################################
    # add the old server settings as default
    foreach $key (keys %{$self->{'FILECONF'}->{'server'}}) {
	if (exists $flconfig{'server'}{$key} && (! $self->{'CONFIG'}->{'noserveroverride'})) {
	    # server already there, don't add the old one
	    $self->debug("server $key is already in config hash, will not add");
	} else {
	    # add old server
	    $flconfig{'server'}{$key} = $self->{'FILECONF'}->{'server'}{$key};
		$self->debug("adding $key to server hash");
	}
    }

    return %flconfig;
}

########################################################################################
##
sub _makeExportPath ($) {
      my $self = shift;
      # make the new path, put the staging dir (gcc... first)
      my $path = $self->{'CONFIG'}->{'root_dir'} . "/staging/usr/bin:".
	$self->{'CONFIG'}->{'root_dir'} . "/staging/bin:" .
	  $ENV{'PATH'};
      return $path;
}
########################################################################################
##

sub _makeEnvString ($$) {
  my $self = shift;
  my %config = @_;
  my $envstring = "";
  $self->debug("starting");
  foreach my $file (keys %config) {
    if (exists($config{$file}{'envname'}) && ($config{$file}{'envname'} ne "")) {
      if ($config{$file}{'envname'} =~ /^[0-9a-zA-Z_-]+$/) {
	$envstring .= " " . $config{$file}{'envname'} . "=" . $file;
      } else {
	# die , not allowed to use
	# maybe change to an error message and do not die...
	confess "not allowed characters in environment varname : ".$config{$file}{'envname'};
      }
    }
  }
  # if we have something we should add to environment, do it
  if ($self->{'ENVIRONMENT'}) {
    $envstring .= " ".$self->{'ENVIRONMENT'};
  }

  $self->debug("envstring=$envstring");
  return $envstring;
}

########################################################################################
## internal method to call make
sub _callMake($$$$) {
  my $self = shift;
  my $type = shift || confess("no type given");
  my $part = shift || confess("no part given");
  my $envstring = shift || confess("no envstring");
  my $dldir = $self->_getSourceDir($part);
  my $log = $self->absoluteFilename($self->{'CONFIG'}{'logfile'});

  confess ("unknown type $type") if ($type ne "source" and $type ne "build") ;

  my $exportPath = $self->_makeExportPath();

  print "calling 'make ". $type . "' for $part ";
  system("export PATH=". $exportPath . " && ". $self->{'ITRACE'} ."make -C ".$dldir. " -f ./".$self->{'CONFIG'}{'buildtool_makefile'}." ". $type ." MASTERMAKEFILE=".$self->{'CONFIG'}{'root_dir'}. "/make/MasterInclude.mk". " BT_BUILDROOT=". $self->{'CONFIG'}{'root_dir'}." ". $envstring. " >>".$log. " 2>&1" ) == 0
    or die "make $type ". $self->make_text_red("failed")." for $dldir/".$self->{'CONFIG'}{'buildtool_makefile'}." , please have a look at the logfile " . $self->{'CONFIG'}{'logfile'};
  # everything is ok, print it:
  $self->print_ok();
  print "\n";



}

sub _getType() {
    return "source";
}





########################################################################################
##
sub _makeCompleteList($) {
    my $self = shift;
    my $type = $self->_getType();
    my @list ;
    my @dep;
    my $part;
    $self->debug("starting for type $type");

    if (@_) {
	@list = @_;
    } else {
	# we habe nothing to do, so return!
	$self->debug("list is empty, returning");
	return ();
    }

	my $p_l_dllist = [];
    #my @dllist = ();

    foreach $part (@list) {
	# now get the list of required sources/packages:

	@dep = $self->getRequireList($part);
	# have a look if we already have done this in the past



	foreach my $deppack (@dep) {
	    if ($self->searchInstalled4Pkg($type, $deppack)) {
		$self->debug("$type already done for $part");
		next;
	    } else {
		$self->debug("$deppack added to complete list list");
		push @{$p_l_dllist}, $deppack;
	    }
	}
	# now look at the list, if the force switch is given we want to
	# source the packages/sources we got from the commandline,
	# so add them if needed
	if ($self->{'CONFIG'}{'force'}) {
	      $self->debug("force enabled");
	      if ($self->isInList($part,@{$p_l_dllist}) == 0) {
		    push @{$p_l_dllist}, $part;
	      }
	}
  }

  my $p_l_downloadList = [];
  my $p_h_packages = {};

  # Remove duplicates from the required-list
  foreach my $package (@{$p_l_dllist}) {
    next if exists($p_h_packages->{$package});
    $p_h_packages->{$package} = 1;

    push(@{$p_l_downloadList},$package);
  }

  return @{$p_l_downloadList};
}

1;
