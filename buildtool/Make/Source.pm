# $Id: Source.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
package buildtool::Make::Source;

use strict;

use Carp;
use Config::General qw( ParseConfig );

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

        # make the environment vars ready:
        # those vars can be set in the buildtool.cfg via a env = NAME entry
        # this would result in NAME=$filename entry
        my $envstring = "";

        # make the envstring
        $envstring = $self->_makeEnvString( %{ $pkg_config{'file'} } );
        my $downloadOnly = 0;
        $downloadOnly = 1
          if exists( $self->{'CONFIG'}{'downloadonly'} )
              && $self->{'CONFIG'}{'downloadonly'};

        if ( !$downloadOnly ) {
            # now call make source
            $self->_callMake( "source", $part, $envstring );

            # add to list
            $self->addEntry( "source", $part );
            $self->writeToFile();
        }
    }
}

########################################################################################
sub _downloadBuildtoolCfg ($$$) {
    my $self = shift;
    my $part = shift;
    my $mdir;
    my %allfiles = $self->_getAllHash();
    my %server   = %{ $self->{'FILECONF'}->{'server'} };

    if ( exists $allfiles{$part}{'directory'} ) {
        $mdir = $allfiles{$part}{'directory'};
    } else {
        $mdir = "";
    }

    # download the buildtool config gile

    my %files = (
                  $self->{'CONFIG'}{'buildtool_config'} => {
                                     'revision' => $allfiles{$part}{'revision'},
                                     'server'   => $allfiles{$part}{'server'},
                                     'directory' => $mdir
                  }
                );

    # first get the config file we want:
    my $download = buildtool::Download->new( $self->{'CONFIG'} );
    $download->setServer( \%server );
    $download->setFiles( \%files );
    $download->setDlroot( $self->_getSourceDir($part) );
    $download->download();
}

1;
