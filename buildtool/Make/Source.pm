package buildtool::Make::Source;

use strict;
use Carp;

use parent qw< buildtool::Make >;

##############################################################################
sub _getType() {
    return "source";
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
    my $self   = shift;
    my @dllist = ();
    ## my $cfg = $self->{'FILECONF'};
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
        %server = %{ $self->{'FILECONF'}->{'server'} };

        print "\nsource/package: $part\n";
        print "------------------------\n";

        # download buildtool.cfg only if we are in source mode,
        # if build this should already happened
        $self->_downloadBuildtoolCfg($part);

        # Read the package config
        my %pkg_config = $self->_readBtConfig($part);

        # now download the complete list of files:
        $download = buildtool::Download->new( $self->{'CONFIG'} );
        $download->setServer( $pkg_config{'server'} );
        $download->setFiles( $pkg_config{'file'} );
        $download->setDlroot( $self->_getSourceDir($part) );
        $download->download();

        # Extract environment from package config
        my $localEnv = $self->_extractLocalEnv( \%pkg_config );

        my $downloadOnly = 0;
        $downloadOnly = 1
          if exists( $self->{'CONFIG'}{'downloadonly'} )
              && $self->{'CONFIG'}{'downloadonly'};

        if ( !$downloadOnly ) {
            # now call make source
            $self->_callMake( "source", $part, $localEnv );

            # add to list
            $self->addEntry( "source", $part );
            $self->writeToFile();
        }
    }
}

########################################################################################
sub _downloadBuildtoolCfg {
    my ( $self, $package, %options ) = @_;
    my $mdir;

    $options{quiet} = 0 unless exists $options{quiet};

    my %pkgs = $self->_getAllHash();
    die("'$package' is not a package nor a source!\n") unless exists $pkgs{$package};

    my %server   = %{ $self->{'FILECONF'}->{'server'} };

    if ( exists $pkgs{$package}{'directory'} ) {
        $mdir = $pkgs{$package}{'directory'};
    } else {
        $mdir = "";
    }

    # download the buildtool config gile

    my %pkg_config_file = (
                  $self->{'CONFIG'}{'buildtool_config'} => {
                                     'revision' => $pkgs{$package}{'revision'},
                                     'server'   => $pkgs{$package}{'server'},
                                     'directory' => $mdir
                  }
                );

    # first get the config file we want:
    my $download = buildtool::Download->new( $self->{'CONFIG'} );
    $download->setServer( \%server );            # Which server to use
    $download->setFiles( \%pkg_config_file );    # File(s) to download
    $download->setDlroot( $self->_getSourceDir($package) );  # Where to download
    $download->download( quiet => $options{quiet} );         # Download !!!
}


########################################################################################
sub dump_env {
    my ( $self, %options ) = @_;

    my $pkg         = $options{package} || '';
    my $output_file = $options{output};
    my $localEnv;

    $options{quiet} = 0 unless exists $options{quiet};

    # If a package is specified we need to download the package config file
    if ($pkg) {
        # the download function wants two hashes: one for the files,
        # and one for the servers (that's the easy part) ;-)

        # download package config file
        $self->_downloadBuildtoolCfg( $pkg, quiet => 0 );

        # Read the package config
        my %pkg_config = $self->_readBtConfig($pkg);

        # Extract environment from package config
        $localEnv = $self->_extractLocalEnv( \%pkg_config );

        if ($output_file) {
            print "\ndumping environment of '$pkg' to $output_file\n";
        } else {
            print "\ndump environment: $pkg\n";
            print "------------------------\n";
        }
    }

    $self->_dumpEnv( %options, localenv => $localEnv );
}

1;
