#
# Bering-uClibc 5.x Copyright (C) 2012 Yves Blusseau
#
package buildtool::Make;

use strict;

use Carp;
use List::MoreUtils qw( uniq );

use parent qw< buildtool::Common::InstalledFile >;

##############################################################################
sub new {
    my $proto    = shift;
    my $globConf = shift || confess("no globConf given");
    my $fileConf = shift || confess("no fileConf given");
    my $class    = ref($proto) || $proto;
    my $self     = $class->SUPER::new($globConf);

    # add fileconf to myself
    $self->{'FILECONF'} = $fileConf;

    # don't use _initialize here!
    # it is called by the super::new.
    $self->{'DEBUG'} = 1;

    bless ($self, $class); # reconsecrate

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
sub _makeCompleteList($) {
    my $self = shift;

    my $type = $self->_getType();

    $self->debug("starting for type $type");

    my @list = @_;
    if ( @list == 0 ) {    # we habe nothing to do, so return!
        $self->debug("list is empty, returning");
        return ();
    }

    my @require_list = ();

    foreach my $part (@list) {

        # now get the list of required sources/packages:
        my @dep = $self->getRequireList($part);

        # add dependencies that are not already done (source/build)
        foreach my $deppack (@dep) {
            if ( $self->searchInstalled4Pkg( $type, $deppack ) ) {
                $self->debug("$type already done for $deppack");
                next;
            } else {
                $self->debug("$deppack added to required $type list");
                push @require_list, $deppack;
            }
        }

        # now look at the list, if the force switch is given we want to
        # source/build the packages/sources we got from the commandline,
        # so add them if needed
        if ( $self->{'CONFIG'}{'force'} ) {
            $self->debug("force enabled");
            push @require_list, $part
              unless $self->isInList( $part, @require_list );
        }
    }

    # Remove duplicates and return the required-list
    return uniq(@require_list);
}

##############################################################################
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

##############################################################################
sub _readBtConfig ($$) {
    my $self = shift;
    my $pkgname = shift || confess("no filename given");

    my $source_dir = $self->{'CONFIG'}{'source_dir'};

    # substitute environment variables like $GNU_TARGET_NAME
    $source_dir =~ s/\$(\w+)/$ENV{$1}/g;
    my $configFile =
      $self->absoluteFilename(   $source_dir . "/"
                               . $pkgname . "/"
                               . $self->{'CONFIG'}{'buildtool_config'} );

    # now make a recursive download of all the files in there
    my %flconfig =
      Config::General::ParseConfig( "-ConfigFile"     => $configFile,
                                    "-LowerCaseNames" => 1 );

    %flconfig = $self->_addDefaultServer(%flconfig);
    return %flconfig;
}

##############################################################################
##
sub _addDefaultServer ($$) {
    my $self     = shift;
    my %flconfig = @_;
    my $key;

    if ( $self->{'CONFIG'}->{'noserveroverride'} ) {
        $self->debug("Override package config servers is enabled!");
    }
    ##############################################
    # add the old server settings as default
    foreach $key ( keys %{ $self->{'FILECONF'}->{'server'} } ) {
        if ( exists $flconfig{'server'}{$key}
             && ( !$self->{'CONFIG'}->{'noserveroverride'} ) ) {

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

##############################################################################
# return the the environment vars:
# those vars can be set in the buildtool.cfg via a env = NAME entry
# this would result in NAME=$filename entry
sub _makeEnvString {
    my $self      = shift;
    my %config    = @_;
    my $envstring = "";
    $self->debug("starting");
    foreach my $file ( keys %config ) {
        if ( exists( $config{$file}{'envname'} )
             && ( $config{$file}{'envname'} ne "" ) ) {
            if ( $config{$file}{'envname'} =~ /^[0-9a-zA-Z_-]+$/ ) {
                $envstring .= " " . $config{$file}{'envname'} . "=" . $file;
            } else {
                # die , not allowed to use
                # maybe change to an error message and do not die...
                confess "not allowed characters in environment varname : "
                  . $config{$file}{'envname'};
            }
        }
    }

    # if we have something we should add to environment, do it
    if ( $self->{'ENVIRONMENT'} ) {
        $envstring .= " " . $self->{'ENVIRONMENT'};
    }

    $self->debug("envstring:$envstring");
    return $envstring;
}

##############################################################################
## returns list of all source or package names
sub _getNameList($$) {
    my $self = shift;
    my $type = shift;
    if ( $type eq "package" or $type eq "source" ) {
        return keys %{ $self->{'FILECONF'}{$type} };
    }
    if ( $type eq "all" ) {
        return ( keys %{ $self->{'FILECONF'}{'source'} },
                 keys %{ $self->{'FILECONF'}{'package'} } );
    }
    # else
    confess("unknown type $type");
}


##############################################################################
# returns a hash with all packages and sources together (no need to
# do a $cfg->{'package'} anymore...
sub _getAllHash ($) {
    my $self = shift;
    my %newhash = (
                    %{ $self->{'FILECONF'}->{'package'} },
                    %{ $self->{'FILECONF'}->{'source'} }
                  );
    return %newhash;
}

##############################################################################
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

##############################################################################
##
sub _makeExportPATH ($) {
    my $self = shift;

    # make the new path, put the staging dir (gcc... first)
    my $path =
        $self->{'CONFIG'}->{'root_dir'}
      . "/staging/usr/bin:"
      . $self->{'CONFIG'}->{'root_dir'}
      . "/staging/bin:"
      . $ENV{'PATH'};
    return $path;
}

##############################################################################
## internal method to call make
sub _callMake($$$$) {
    my $self      = shift;
    my $target    = shift || confess("no target rule given");
    my $part      = shift || confess("no part given");
    my $envstring = shift || confess("no envstring");
    my $dldir     = $self->_getSourceDir($part);
    my $log       = $self->absoluteFilename( $self->{'CONFIG'}{'logfile'} );

    my $exportPATH = $self->_makeExportPATH();

    my $commandStr =
        "export PATH=" . $exportPATH . " && " . $self->{'ITRACE'}
      . "make -C " . $dldir
      . " -f ./" . $self->{'CONFIG'}{'buildtool_makefile'} . " "
      . $target
      . " MASTERMAKEFILE=" . $self->{'CONFIG'}{'root_dir'} . "/make/MasterInclude.mk"
      . " BT_BUILDROOT="   . $self->{'CONFIG'}{'root_dir'} . " "
      . $envstring . " >>" . $log . " 2>&1";

    $self->debug("starting command:$commandStr");
    print "calling 'make " . $target . "' for $part ";
    system($commandStr ) == 0
      or die "make $target "
      . $self->make_text_red("failed")
      . " for $dldir/" . $self->{'CONFIG'}{'buildtool_makefile'}
      . " , please have a look at the logfile " . $self->{'CONFIG'}{'logfile'};

    # everything is ok, print it:
    $self->print_ok();
    print "\n";
}

1;
