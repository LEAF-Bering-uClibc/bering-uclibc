# $Id: FileTrace.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $
#

package buildtool::Common::FileTrace;

use buildtool::Common::Object;
use File::Find;

use vars qw(@ISA);

@ISA = qw(buildtool::Common::Object);

sub _initialize {
	my $self = shift;
	$buildtool::Common::FileTrace::time = time();
	@buildtool::Common::FileTrace::dirlist = ();
	@buildtool::Common::FileTrace::filelist = ();
        my %params = @_;		
	$self->{'startList'} = $self->{'CONFIG'}->{'tracepath'};
	$self->SUPER::_initialize();
	$self->{'part'} = $params{'part'};
	$self->debug("Filetrace starting for part ". $self->{'part'});
	# add every dir to our list at startup:
	foreach my $name (@{$self->{'startList'}}) {
		$name = $self->absoluteFilename($name);
		find(\&buildtool::Common::FileTrace::mkDirList, ($name));
	}		
}

sub mkDirList {
	my $filename = $File::Find::name;
	if (-d $filename) {
		push @buildtool::Common::FileTrace::dirlist, $filename;
	}	
}

sub matches {
	my $searchfor = shift;
	my @files = @_;
	foreach my $file (@files) {
		if ($file eq $searchfor) {
			return 1;
		}
	}
	return 0;

}
# create the file list
sub getFileList {
	my $self = shift;
	foreach my $name (@{$self->{'startList'}}) {
		$buildtool::Common::FileTrace::dirName = $self->absoluteFilename($name);
		find(\&buildtool::Common::FileTrace::wanted, ($name));
	}		
	

}

sub wanted {
	my $dirname = $File::Find::name; 
	my @fileinfo = stat($dirname);
	if ($fileinfo[10] and $fileinfo[10] >= $time) {
		if (-d $dirname) {
			if (! &matches($dirname, @buildtool::Common::FileTrace::dirlist)) {
				push @buildtool::Common::FileTrace::filelist, $dirname;
			}
		} else {
			push @filelist, $dirname;
		}
	}
}

sub writeToFile {
	my $self = shift;
	my $file = $self->absoluteFilename($self->{'CONFIG'}->{'buildtracedir'}) ."/". $self->{'part'}. ".list";
	$self->debug("opening $file for writing");
	open WRITEFILE, ">$file" or die("unable to open file $file for writing");
		foreach my $file (@buildtool::Common::FileTrace::filelist) {
			  print WRITEFILE $file . "\n";
		}	
	close WRITEFILE
}





1;
