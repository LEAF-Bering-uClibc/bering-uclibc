# $Id: Download.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $

package buildtool::Download;

use buildtool::DownloadTypes::ViewCVS;
use buildtool::DownloadTypes::Gitweb;
use buildtool::DownloadTypes::Http;
use buildtool::DownloadTypes::Ftp;
use buildtool::DownloadTypes::File;
use buildtool::DownloadTypes::FileSymlink;
use buildtool::Common::Object;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Common::Object);

############################################################################
sub setServer ($$) {
  my $self = shift;
  my $servref = shift;
  confess "no server hash given" if (ref($servref) ne "HASH");
  $self->{'SERVER'} = $servref;
}

############################################################################
sub setDlroot ($$) {
  my $self = shift;
  my $dlroot = shift;
  confess("no dlroot given") if ($dlroot eq "" or !$dlroot);
  $self->debug("setting dlroot to : $dlroot");
  $self->{'DLROOT'} = $dlroot;
}

############################################################################
sub setFiles ($$) {
  my $self = shift;
  my $filesref = shift;
  confess "no files hash given" if (ref($filesref) ne "HASH");
  $self->{'FILES'} = $filesref;
}



############################################################################
# make the actual download,
# needs the folowing arguments:
# server (hashref) as from Config::General
# file (hashref) as from Config::General
# dlroot (string)
sub download () {
  my $self = shift;
  my %myconf = %{$self->{'CONFIG'}};

  my $dir = "";
  my $server = $self->{'SERVER'};

  my %files = %{$self->{'FILES'}} ;
  my $dlroot = $self->{'DLROOT'};

  if ( -d $dlroot) {
    # do nothing right now

  } else {
    # mkdir
    system("mkdir", "-p", "$dlroot") == 0
      or confess "mkdir $dlroot failed";
  }

  confess "no server set" if (ref($server) ne "HASH");


  foreach my $file (keys %files) {
    $self->debug("file key: $file");
    my $dlserver = $files{$file}{'server'} ;
    my $srcfile = $files{$file}{'srcfile'};
    confess "empty entry for server in file section for $file"
      if ($dlserver eq "");

    #check for server:
    if (ref($server->{$dlserver}) ne "HASH") {
      $self->die("maybe config error:","unknown server $dlserver");
    }

    my $dltype = $server->{$dlserver}{'type'};

    $self->die("Error in Config:","no server type given for server $dlserver") if ((! $dltype) or ($dltype eq ""));

    print "downloading: $file from server $dlserver type $dltype ";

  if ($myconf{'nodownload'}) {
	$self->debug("not downloading anything as requested by commandline");
	print $self->make_text_green("[skipped]") . "\n";
	return;
  }



    # check if there is a directory entry in the section else use nothing
    my $spath = "";

    if (exists $files{$file}{'directory'} and $files{$file}{'directory'}) {
      $dir = $files{$file}{'directory'}
    } else {
      $dir = "";
    }

    $spath = $self->strip_slashes($server->{$dlserver}{'serverpath'});

    # first add to conf what we need all:_
    my %allconf = ('config' => \%myconf,
		   'dlroot' => $dlroot,
		   'serverpath' => $spath,
		   'filename' => $file,
		   'dir' => $dir,
		   'srcfile' => $srcfile
		   );

	my $dlpath;
    if (exists $files{$file}{'dlpath'} and $files{$file}{'dlpath'}) {
      $dlpath = $files{$file}{'dlpath'}
    } else {
      $dlpath = undef;
    }


    if ($dltype eq "http") {
      # download via http

	  my $object = buildtool::DownloadTypes::Http->new(%allconf,(
								     'server' => $server->{$dlserver}->{'name'},
								    )
							  );
       	  
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);

    } elsif ($dltype eq "ftp") {
      # download via ftp
      my $object = buildtool::DownloadTypes::Ftp->new(%allconf,(
								 'server' => $server->{$dlserver}->{'name'},
										  )
						      );
       
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);

    } elsif ($dltype eq "file") {
      # local file


      $allconf{'dlpath'} = $dlpath if defined($dlpath);

      my $object = buildtool::DownloadTypes::File->new(%allconf);
      # check if download was successful, if not, die with an error message:
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);

    } elsif ($dltype eq "filesymlnk") {
      # local file


      $allconf{'dlpath'} = $dlpath if defined($dlpath);

      my $object = buildtool::DownloadTypes::FileSymlink->new(%allconf);
      # check if download was successful, if not, die with an error message:
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);

    } elsif ($dltype eq "viewcvs") {
      my $revision = $files{$file}{'revision'};
       if (!$revision || $revision eq "") {
	# something wrong
	$self->die("error in config","revision is missing for file $file, required for type viewcvs");
      }

      # else everything is alright
      # download via viecvs.
      my $object = buildtool::DownloadTypes::ViewCVS->new(%allconf,(
								     'server' => $server->{$dlserver}->{'name'},
								     'revision' => $revision
								    )
							  );
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);
    } elsif ($dltype eq "gitweb") {
      my $revision = $files{$file}{'revision'};
      my $repo = ($files{$file}{'repo'}) ? $files{$file}{'repo'} : $server->{$dlserver}->{'repo'};
       if (!$revision || $revision eq "") {
	# something wrong
	$self->die("error in config","revision is missing for file $file, required for type viewcvs");
      }

      # else everything is alright
      # download via viecvs.
      my $object = buildtool::DownloadTypes::Gitweb->new(%allconf,(
								     'server' => $server->{$dlserver}->{'name'},
								     'revision' => $revision,
								     'repo' => $repo
								    )
							  );
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);
    } elsif ($dltype eq "cvspserver") {
	  # try to load pserver:
	  eval "use buildtool::DownloadTypes::CvsPserver";
	  if ($@) {
		$self->die("loading  buildtool::DownloadTypes::CvsPserver failed!", "if you want to use pserver support install libcvs-perl(>=1.001) from: https://libcvs.cvshome.org/"); 
	  }

	my $revision = $files{$file}{'revision'};
       if (!$revision || $revision eq "") {
	# something wrong
	$self->die("error in config","revision is missing for file $file, required for type viewcvs");
      }
      # else everything is alright
      # download via viecvs.
      my $object = buildtool::DownloadTypes::CvsPserver->new(%allconf,(
								     'server' => $server->{$dlserver}->{'name'},
								     'revision' => $revision,
								     'cvsroot' => $server->{$dlserver}->{'cvsroot'},
								     'username' => $server->{$dlserver}{'username'},
								     'password' =>$server->{$dlserver}{'password'}	
								    )
							  );
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);



    } elsif ($dltype eq "cvsext") {
	  # try to load :
	  eval "use buildtool::DownloadTypes::CvsExt";
	  if ($@) {
		$self->die("loading  buildtool::DownloadTypes::CvsPserver failed!", "if you want to use pserver support install libcvs-perl(>=1.001) from: https://libcvs.cvshome.org/"); 
	  }

	my $revision = $files{$file}{'revision'};
       if (!$revision || $revision eq "") {
	# something wrong
	$self->die("error in config","revision is missing for file $file, required for type viewcvs");
      }
      # else everything is alright
      # download via viecvs.
      my $object = buildtool::DownloadTypes::CvsExt->new(%allconf,(
								     'server' => $server->{$dlserver}->{'name'},
								     'revision' => $revision,
								     'cvsroot' => $server->{$dlserver}->{'cvsroot'},
								     'username' => $server->{$dlserver}{'username'},
								     'password' =>$server->{$dlserver}{'password'}	
								    )
							  );
      $self->die("download failed", $object->getErrorMsg() . " \n") if  ($object->download()== 0);




    } else {
      confess("unknown type $dltype");
    }
    # not died, so everything seems to be o.k.
    $self->printOk();
    print "\n";
  }
}




1;
