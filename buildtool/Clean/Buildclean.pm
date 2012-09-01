
package buildtool::Clean::Buildclean;

use strict;
use Carp;

use parent qw< buildtool::Make buildtool::Clean >;

###############################################################################
sub clean () {
  my $self = shift;
  my $pkg ;

  my @list = @_ ? @_ : $self->getEntries("build");

  foreach $pkg (@list) {
    # first have a look if already deleted:
    # if yes, do nothing!
    if ( !$self->searchInstalled4Pkg( "build", $pkg ) ) {
        $self->debug("$pkg is not in build list, maybe already cleaned!\n");
        if ( !$self->{'CONFIG'}{'force'} ) {
            # force is not enabled, so continue with next one
            next;
        } else {
            $self->debug("force enabled, trying to remove anyway");
        }
    }

    # Read the package config
    my %pkg_config = $self->_readBtConfig($pkg);

    # Populate the envstring from file section of package config
    my $envstring  = $self->_makeEnvString( %{ $pkg_config{'file'} } );

    # now call make clean
    $self->_callMake("clean", $pkg, $envstring);

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
    my $pkg  = shift;
    my $file = $self->_getInstalledListFileName($pkg);
    return $self->_removeFile($file);
}

###############################################################################
# remove the package files
sub _removePackageFiles () {
    my $self = shift;
    my $pkg  = shift;

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
    return
      $self->absoluteFilename( $self->{'CONFIG'}{'buildtracedir'} ) . "/"
      . "$pkg" . ".list";
}

###############################################################################
sub _getFileList () {
    my $self     = shift;
    my $pkg      = shift;
    my $filename = $self->_getInstalledListFileName($pkg);
    my @list     = ();

    # check if file exists:
    if ( -e $filename and ( -f $filename > 0 ) ) {
        my $fh = Symbol::gensym();

        open( $fh, '< ' . $filename );
        while ( my $line = <$fh> ) {
            chop $line;
            if ( $line ne "" ) {
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
