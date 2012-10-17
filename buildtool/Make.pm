#
# Bering-uClibc 5.x Copyright (C) 2012 Yves Blusseau
#
package buildtool::Make;

use strict;
use Carp;

use File::Spec;
use Hash::Merge;
use List::MoreUtils qw( uniq );

use buildtool::Tools qw< readBtConfig >;

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
    $self->{'ENVIRONMENT'} = { 'LANG' => 'C' };

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

    my $configFile =
      $self->absoluteFilename(
                File::Spec->catfile(
                    $source_dir, $pkgname, $self->{'CONFIG'}{'buildtool_config'}
                                   )
                             );

    # now read the package config file
    my %flconfig = readBtConfig(
        "ConfigFile"    => $configFile,
        "DefaultConfig" => $self->{'CONFIG'}, # Add variables from global config
    );

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
# return a hash containing the local environment vars:
# those vars can be set in the buildtool.cfg via a env = NAME entry
# this would result in NAME=$filename entry
sub _extractLocalEnv {
    my ( $self, $pkgConfig ) = @_;

    $self->debug("starting");

    my $pkg_envvars = $pkgConfig->{'envvars'} || {};
    my $environment = $self->{'ENVIRONMENT'}  || {};
    my $merge       = Hash::Merge->new('RIGHT_PRECEDENT');
    my $localEnv = $merge->merge( $environment, $pkg_envvars );

    # Convert envvars keys to uppercase
    $localEnv = {
                  map { uc $_ => $localEnv->{$_} }
                    keys %{$localEnv}
                };

    # Extract environment variables from file sections of package config
    my $files = $pkgConfig->{file};
    foreach my $file ( keys %{$files} ) {
        my $file_hash = $files->{$file};
        if ( exists $file_hash->{'envname'} and $file_hash->{'envname'} ) {
            my $var = $file_hash->{'envname'};
            if ( $var =~ /^[0-9a-zA-Z_-]+$/ ) {
                $localEnv->{$var} = $file;
            } else {
                # die , not allowed to use
                # maybe change to an error message and do not die...
                confess "not allowed characters in environment varname '$var'";
            }
        }
    }

    return $localEnv;
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
    my $path = join(
                     ':',
                     File::Spec->catdir(
                                          $self->{'CONFIG'}->{'root_dir'},
                                          '/staging/usr/bin'
                                        ),
                     File::Spec->catdir(
                                          $self->{'CONFIG'}->{'root_dir'},
                                          '/staging/bin'
                                        ),
                     $ENV{'PATH'}
                   );
    return $path;
}

##############################################################################
##
sub _export_env_by_format {
    my ( $self, %options ) = @_;
    my $output_fh = $options{output_fh} || *STDOUT;
    my $key       = $options{key}       || die "You must specified a key";
    my $value     = $options{value}     || die "You must specified a value";
    my $format    = $options{format}    || 'shell';

    if ( $format eq 'shell' ) {
        print $output_fh "export $key='$value'", $/;
    } elsif ( $format eq 'makefile' ) {
        $value =~ s/ /\\ /g;    # Escape space
        print $output_fh "export $key = $value", $/;
    } else {
        die "Unknown output format '$format'";
    }

    $self->debug("Environment variable \$$key set to '$value'");
}

##############################################################################
## dump the environment on screen or file
## Options:
##    localenv  => hash ref containing key/values pairs to dump (optional)
##    output_fh => filehandle where the environment will be dump
##                 (default STDOUT)
##    format    => format of the dump. Can be 'shell' or 'makefile'
##                 (default 'shell')
sub _dumpEnv {
    my ( $self, %options ) = @_;
    my $output_fh;

    my $localEnv  = $options{localenv}           || {};
    my $globalEnv = $self->{'CONFIG'}->{envvars} || {};

    # Merge the 2 environments. Priority to localEnv
    my $merge = Hash::Merge->new('RIGHT_PRECEDENT');
    my $mergedEnv = $merge->merge( $globalEnv, $localEnv );

    # Dump merged environment
    foreach my $var ( sort keys %{$mergedEnv} ) {
        my $value = $mergedEnv->{$var};
        if ( not ref $value ) {    # value is a scalar
            $self->_export_env_by_format(
                                          %options,
                                          'key'       => $var,
                                          'value'     => $value,
                                        );
        }
    }
}


##############################################################################
## internal method to call make
sub _callMake {
    my $self      = shift;
    my $target    = shift || confess("no target rule given");
    my $part      = shift || confess("no part given");
    my $localEnv  = shift || confess("no localEnv");
    my $dldir     = $self->_getSourceDir($part);
    my $log       = $self->absoluteFilename( $self->{'CONFIG'}{'logfile'} );

    my $exportPATH = $self->_makeExportPATH();

    # Create the Makefile
    my $makefileFile = File::Spec->catfile( $dldir, 'Makefile' );
    open my $output_fh, ">$makefileFile"
      or croak "Can't create $makefileFile:$!";
    print $output_fh "#\n# This file was automaticaly generated\n#\n";
    my $merge = Hash::Merge->new('RIGHT_PRECEDENT');
    my $updateLocalEnv = $merge->merge( { PATH => $exportPATH }, $localEnv );
    $self->_dumpEnv(
                     output_fh => $output_fh,
                     localenv  => $updateLocalEnv,
                     format    => 'makefile'
                   );
    printf $output_fh "\ninclude %s",   '$(BT_MASTERMAKEFILE)';
    printf $output_fh "\ninclude %s\n", $self->{'CONFIG'}{'buildtool_makefile'};
    close $output_fh;

    my $commandStr =
      "make -C " . $dldir . "  " . $target . " >>" . $log . " 2>&1";

    $self->debug("starting command: $commandStr");
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
