package buildtool::DownloadTypes::GitAnnex;

# "download type" that allows to download from a
# git-annex repository

# sample buildtool.cfg:
#
#
#<Server leaf-storage>
#	Type = git-annex
#	basepath = repo
#</Server>
#
#
#<File linux-2.4.20.tar.bz2>
#	Server = leaf-storage
#	Directory = linux
#</File>
#
# if this is for the package "kerneltest" this means:
# the file will be download to $BT_ROOT/repo/linux/linux-2.4.20.tar.bz2
# and a link will be create from $BT_ROOT/source/kerneltest/linux-2.4.20.tar.bz2
# to the new downloaded file

use strict;
use Carp;
use File::Spec;
use buildtool::Common::Object;
use Data::Dumper;

use vars qw(@ISA $VERSION);
@ISA		= qw(buildtool::Common::Object);


sub new($$)
{
	my ($type, %params) = @_;

	foreach my $name ("config", "basepath", "filename") {
		if (!(exists($params{$name}) && $params{$name})) {
			confess ("no " . $name . " given");
		}
	}

	my $self = $type->SUPER::new(\%{$params{'config'}}, %params);

	$self->_initialize(%params);

	return($self);
}

sub _initialize($$) {
    my ( $self, %params ) = @_;
    $self->debug("GitAnnex starting");

    $self->debug("buildtool::DownloadTyped::GitAnnex _initialize called");
    $self->{'FILENAME'} = $params{'filename'};
    if ( $params{'srcfile'} and $params{'srcfile'} ne "" ) {
        $self->{'IFILENAME'} = $params{'srcfile'};
        $self->debug("Set IFILE from srcfile");
    }
    else {
        $self->{'IFILENAME'} = $params{'filename'};
    }
    $self->{'SOURCEFILE'} = $self->stripSlashes(
        $self->absoluteFilename(
            File::Spec->catfile(
                $params{'basepath'}, $params{'dir'},
                $self->{'IFILENAME'}
            )
        )
    );
    $self->{'FULLPATH'} = $self->stripSlashes(
        File::Spec->catfile( $params{'dlroot'}, $self->{'FILENAME'} ) );
}

sub download($) {
    my ($self) = @_;
    my @cmd;

    if ( !$self->overwriteFileOk( $self->{'SOURCEFILE'} ) ) {
        $self->logme( "not overwriting file "
              . $self->{'SOURCEFILE'}
              . " as requested" );
    }
    else {
        @cmd = (
            $self->absoluteFilename('tools/annex'),
            'get', "'$self->{'SOURCEFILE'}'"
        );
        my $command = join ' ', @cmd;
        my $command_out = `$command 2>&1`;
        my $exit_code = $? >> 8;

        if ( $exit_code != 0 ) {
            my $msg = "annex failed: $command:\n$command_out";
            $self->debug($msg);
            $self->_setErrorMsg($command_out);
            return 0;
        }
    }
	
    @cmd = ( 'ln', '-sf', $self->{'SOURCEFILE'}, $self->{'FULLPATH'} );

	$self->debug( "calling ln with:" . join( " ", @cmd ) );
	if ( ( system( @cmd ) >> 8 ) != 0 ) {
		my $msg = "ln failed: " . join( " ", @cmd );
		$self->debug($msg);
		$self->_setErrorMsg($msg);
		return 0;
    }

    # give back true return code
    return 1;
}

1;
