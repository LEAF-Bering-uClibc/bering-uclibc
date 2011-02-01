#$Id: Buildclean.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $

package buildtool::Clean::Buildclean;

use buildtool::Clean;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Clean);

###############################################################################
sub callMakeClean () {
  my $self = shift;
  my $pkg = shift || confess "no pkg given!";
  my $path = $self->_getSourceDir($pkg);

  my %globConf = %{$self->{'CONFIG'}}; 

  print "calling 'make clean' for $pkg: ";
  # check if dir exists, if not, it is o.k.
  $self->dumpIt(\%globConf,0);
  if (! -d $path) {
	$self->debug("$path is not there, might be ok");
  } else {

	system("make -C ".$path. " -f ./".$globConf{'buildtool_makefile'}." clean MASTERMAKEFILE=".$globConf{'root_dir'}. "/make/MasterInclude.mk". " BT_BUILDROOT=". $globConf{'root_dir'}. " >>".$globConf{'logfile'}. " 2>&1" ) == 0
	  or die "make clean ". $self->make_text_red("failed")." for ".$path."/".$globConf{'buildtool_makefile'}." , please have a look at the logfile " . $globConf{'logfile'};
  }
  $self->print_ok();
  print "\n";
  return 1
}


###############################################################################
sub clean () {
  my $self = shift;
  my $pkg ;
  my @list;

  if (@_) {
    @list = @_ ;
  } else {
    # get a list of all pkg/sources that are installed:
    @list = $self->getEntries("build");
  }
  
  foreach $pkg (@list) {
    # first have a look if already deleted:
    # if yes, do nothing!
    if (! $self->searchInstalled4Pkg("build", $pkg)) {
      $self->debug("$pkg is not in build list, maybe already cleaned!\n");
      if (!$self->{'CONFIG'}{'force'}) {
	# force is not enabled, so continue with next one
	next;
      } else {
	$self->debug("force enabled, trying to remove anyway");
      }
    }
    # first call make clean for the package buildtool.mk itself
    $self->callMakeClean($pkg);

    # now remove everything from our list:
    $self->_removePackageFiles($pkg);
    # remove the list
    $self->_removePackageListFile($pkg);

    # remove the pkg name from the list of build files:
    $self->deleteEntry("build", $pkg);
    $self->writeToFile();

  }
}

###############################################################################
# remove the package file list
sub _removePackageListFile () {
  my $self = shift;
  my $pkg = shift;
  my $file = $self->_getInstalledListFileName($pkg);
  return $self->_removeFile($file);
}

###############################################################################
# remove the package files
sub _removePackageFiles () {
  my $self = shift;
  my $pkg = shift;

  print "removing installed files for package $pkg ";
  
  my @filelist = $self->_getFileList($pkg);
  $self->_removeFiles(@filelist);
  
  $self->print_ok();
  print "\n";


}


###############################################################################
sub _getInstalledListFileName () {
  my $self = shift;
  my $pkg = shift || confess "no package name given";
  return $self->absoluteFilename($self->{'CONFIG'}{'buildtracedir'}). "/". "$pkg" . ".list";
}

###############################################################################
sub _getFileList () {
  my $self = shift;
  my $pkg = shift;
  my $filename = $self->_getInstalledListFileName($pkg);
  my @list = ();

  # check if file exists:
  if ( -e $filename and (-f $filename > 0)) {
    my $fh = Symbol::gensym();
    
    open($fh, '< ' . $filename);
    while (my $line = <$fh>) {
      chop $line;
      if ($line ne "") {
	push @list, $line;
      }
    }
    close $fh;
 


  } else {
    $self->debug("$filename is not there or empty");

    }
  return @list;
}

1;
