# This file is should be used whenever you need the installedFile Stuff
#

package buildtool::Common::InstalledFile;

use strict;
use Carp;

use Config::General 2.15;

use parent qw< buildtool::Common::Object >;

######################################################################
# init function
#
sub _initialize() {
    my $self      = shift;
    my %installed = ();

    $self->SUPER::_initialize();

    my $listfile = $self->absoluteFilename( $self->{'CONFIG'}{installedfile} );

    # what type we have
    $self->{'TYPES'} = [ "source", "build" ];
    $self->{'FILENAME'} = $listfile;

    # Default config (empty list)
    my $default_config = {};
    map { $default_config->{$_} = [] } @{ $self->{'TYPES'} };

    # read in the file if it exists
    if ( -e $listfile ) {
        %installed =
          Config::General::ParseConfig( "-ConfigFile"    => $listfile,
                                        "-DefaultConfig" => $default_config );
        $self->debug("reading in installedfile $listfile");
    } else {
        $self->debug("starting with empty installedfile $listfile");
        %installed = %{$default_config};
    }
    $self->{'INSTALLED'} = \%installed;
}

##########################################################
# gets a list back for the given type, returns an array

sub getEntries() {
  my $self = shift ;
  my $type = shift || die "no type given";

  $self->debug("starting");

  # make sure the type is valid!
  $self->checkType($type);


  my %list = %{$self->{'INSTALLED'}};

  if (exists $list{$type}) {
    if (ref($list{$type}) eq "ARRAY") {
      return @{$list{$type}};
    } else {
      return ($list{$type});
    }
  } else {
    $self->debug("type $type does not exist in values");
  }

  return ;
}

##########################################################
# check if Type is valid
sub checkType() {
  my $self = shift;
  my $type = shift || die "no type to check given";
  if ($self->isInList($type, @{$self->{'TYPES'}})) {
    return 1;
  } 
  # else
  $self->debug("unknown type:$type list contains:" . join(",",@{$self->{'TYPES'}}));
  confess "unknown type $type";
}

##########################################################
# search in the installed package list for actual package
sub searchInstalled4Pkg {
    my $self  = shift;
    my $type  = shift || die "no type given";
    my $entry = shift || die "no entry given";

    $self->debug("starting with args '$type','$entry'");

    # make sure the type is valid!
    $self->checkType($type);

    my @list =
      exists $self->{'INSTALLED'}->{$type} # check if the list exists
      ? @{ $self->{'INSTALLED'}->{$type} } # if yes return the list
      : ();                                # or an empty list

    if ( $self->isInList( $entry, @list ) ) {
        $self->debug("entry $entry found in $type list");
        return 1;
    }
    # failed, return 0;
    $self->debug("entry $entry not in $type list");
    return 0;
}

##########################################################
sub deleteEntry {
      my $self = shift;
      my $type = shift || die "no type given";
      my $entry = shift || die "no entry given";
      my $length;

      # make sure the type is valid!
      $self->checkType($type);

      my %list = %{$self->{'INSTALLED'}};

      my $off = -1;
      #make path to file

      $self->debug("starting, entry=$entry, type=$type");

      # show a message:
      print "deleting $entry type $type from installed list ";

      # now search for entry
      # check if entry is already in type...
      if ($self->searchInstalled4Pkg($type, $entry)) {

	    # look if we have an array or just one entry:

	    if (ref($list{$type}) eq "ARRAY") {
		  # yes, we are an array, splice it off.

		  # get the position:
		  $off = $self->getArrayPosition($entry,@{$list{$type}}); 

		  # now cut it from array
		  if ($off >=0) {
			$self->debug("splicing element $off from list");
			splice(@{$list{$type}}, $off, 1);
		  } else {
			$self->logme("off not greater 0, should not happen");
			$self->print_failed();
			print "\n";
			return 0;
		  }

	    }  else {
		  # not an array, but is in list, so must be a single entry
		  # just one entry, delete it:
		  delete $list{$type};
	    }

	    #################### end of searchInstalled4Pkg
      } else {
	    # we have not found the entry we should delete...
	    # search if force is enabled:
	    $self->debug("type $type not in list");

	    if (!$self->{'CONFIG'}->{'force'}) {
		  # force is not enabled!
		  print "$entry is not installed ";
		  $self->print_failed();
		  print "\n";
		  return 0;

	    }
      }
      $self->print_ok();
      print "\n";

      #put back to myself:
      $self->{'INSTALLED'} = \%list;
      # do not automatically save it.
      return 1;

}




##########################################################
# this here writes the list of installed packages/sources
# back to the disc
sub writeToFile {
      my $self = shift;
      $self->debug("starting");

      my %list = %{$self->{'INSTALLED'}};

      ## now save it back
      $self->debug("saving installedfile");
      Config::General::SaveConfig($self->{'FILENAME'}, \%list);
      return 1;
}





##########################################################
# adds one entry to the list
#

sub addEntry () {
      my $self = shift;

      my %list = %{$self->{'INSTALLED'}};
      my $type = shift || die "no type given";
      my $entry = shift || die "no entry given";

      # make sure the type is valid!
      $self->checkType($type);

      # check if entry is already in type...
      if ($self->searchInstalled4Pkg($type, $entry)) {
	    $self->debug("entry $entry is already in list $type, not adding");
	    return 1;
      }

      # else
      # check what type we need to add:
      # if the given type exists and is not
      # an array, convert it to an array
      if (exists $list{$type}) {
	    if (ref($list{$type}) eq "ARRAY") {
		  push @{$list{$type}}, $entry;
		  $self->debug("pushing $entry on list");
	    } elsif ($list{$type}) {
		  my $oldvalue = $list{$type};
		  $list{$type} = [$oldvalue, $entry];
		  $self->debug("pushing $entry and oldvalue on list");
	    } else {
		  die "entry $type in list is neither an ARRAY nor just a value, something is really wrong here";
	    }
      } else {
	    # new value
	    $self->debug("adding new single entry $entry to $type");
	    $list{$type} = $entry;
      }

      # put back the list:
      %{$self->{'INSTALLED'}} = %list;

      return 1;
}

###############################################################################
#
sub _getSourceDir () {
    my $self = shift;
    my $pkg = shift || confess("no pkg given");

    #  if ($pkg eq "") {
    #    return;
    #  }

    my $source_dir = $self->{'CONFIG'}{'source_dir'};

    return $self->absoluteFilename( $source_dir . "/" . $pkg );
}

###############################################################################
# show a list of installed packages/sources
sub showList ($) {
    my ($self)  = @_;
    my @sourced = $self->getEntries("source");
    my @built   = $self->getEntries("build");
    print "\nsourced sources or packages : \n";
    print '-' x 32, $/;
    print @sourced ? join( $/, @sourced ) . $/ : "Nothing sourced yet\n\n";

    print "\nbuilt sources or packages : \n";
    print '-' x 32, $/;
    print @built ? join( $/, @built ) . $/ : "Nothing built yet\n\n";
}

###############################################################################
# show a list of sourced packages/sources
sub showSourcedList {
    my ($self)  = @_;
    my @sourced = $self->getEntries("source");
    print join( $/, @sourced ), $/;
}

###############################################################################
# show a list of built packages/sources
sub showBuiltList {
    my ($self)  = @_;
    my @built   = $self->getEntries("build");
    print join( $/, @built ), $/;
}

1;
