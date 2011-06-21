#$Id: Config.pm,v 1.1.1.1 2010/04/26 09:03:17 nitr0man Exp $

package buildtool::Config;

use buildtool::Common::Object;
use Config::General 2.15;
use Carp;
use strict;

use vars qw(@ISA);

@ISA = qw(buildtool::Common::Object);


sub new($$) {
  # my new function
  my $type = shift || confess("no Type given");
  my $globConf = shift || confess("no globConf given");
  my $fileConf = shift || confess("no fileConf given");

  my $self = $type->SUPER::new($globConf);

  # add fileconf to myself
  $self->setFileConfig($fileConf);
  # don't use _initialize here!

  return $self;
  
}


######################################################
# gets back file config ref
sub getFileConfigRef () {
  my $self = shift;
  return $self->{'FILECONF'};
}


######################################################
# sets the File config
sub setFileConfig () {
  my $self = shift;
  $self->{'FILECONF'} = shift;
}


######################################################
# checks if source or package files are named correctly
sub adjustFileConfig {
  my $self = shift;

  my $cfg = $self->{'FILECONF'};
  my (%oldconf, %newconf, %defconf);


  $self->debug("check_config starting");
  confess("config is not a hash ref") if (ref($cfg) ne "HASH");
  my %list;
  # now have a look at source and package, there should not be
  # the same name in both...
  if (exists $cfg->{'package'} and ref($cfg->{'package'}) eq "HASH") {
    %list = %{$cfg->{'package'}};
  } else {
    logme("check_confignames:something wrong with config hash...");
  }

  foreach my $name (keys(%list)) {
    $self->debug("name:$name");
    die make_text_red("$name is a name for a package AND a source, this can not be, please change in " .make_absolute_path($self->{'CONFIG'}{'globalconffile'})) if (exists $cfg->{'source'}{$name}) ;
  }

  # check for duplicate entries in the sections resulting in an array which may break things:
  foreach my $type (("server", "package", "source")) {
	foreach my $key (keys %{$cfg->{$type}}) {
		# die if array found (should be hash!)
		die("\n". $self->makeTextRed("Error in global.cfg: "). "duplicate entry $key in section $type \n\n") if (ref($cfg->{$type}{$key}) eq "ARRAY");
	}
  }

  # adjust config and include the default settings to each section
  foreach my $type ("package", "source") {
    if (exists $cfg->{$type}{'default'}) {
      # add the default to each package
      foreach my $key (keys %{$cfg->{$type}}) {
	next if($key eq "default");
	# check for nodefault switch!
	next if($cfg->{$type}{$key}{'nodefault'});
	%oldconf = %{$cfg->{$type}{$key}};
	# copy the default in:
	%newconf = %{$cfg->{$type}{'default'}};

	#dump_hash(\%newconf,0);

	# set the new values over the defaults!
	foreach my $oldkey (keys %oldconf) {
	  $newconf{$oldkey} = $oldconf{$oldkey};
	}
	%{$cfg->{$type}{$key}} = %newconf;

	#dump_hash(\%newconf,0);


      }
    }
  }
  return 1;
}
#########################################################
# shows the desciption tag of one or more sources/packages
# or all if no name is given...

sub showDescription {
  my $self = shift;
  my $cfg = $self->{'FILECONF'} ;
  my @pkglist = ();
  my @srclist = ();
  my $pkg;
  my $maxlen = 0;
  my $all = 0;

  confess("fileconf is not a hash reference") if (ref($cfg) ne "HASH");

  if (@_) {
    foreach $pkg (@_) {
      if (exists $cfg->{'package'}{$pkg}) {
	push @pkglist , $pkg;
      } elsif (exists $cfg->{'source'}{$pkg}) {
	push @srclist, $pkg;
      } else {
	print $self->make_text_red("$pkg is not a source or package"). "\n";
      }
    }

  } else {
    $all = 1;
    # get a list of all pkg/srces
    foreach $pkg (keys %{$cfg->{'package'}}) {
      push @pkglist, $pkg;
    }
    foreach $pkg (keys %{$cfg->{'source'}}) {
      push @srclist, $pkg;
    }
  }

  # get the max length of the strings:
  $maxlen = 0;
  foreach my $item (@srclist, @pkglist) {
	if (length($item) > $maxlen) {
	      $maxlen = length($item);
	}
  }
  

  if ($all) {
    print "\nThe following packages and sources are available:\n";
  }

  if (scalar(@srclist) > 0) {
    print "\nSources:\n---------------------------------------------------------\n";
  }
  foreach $pkg (sort @srclist) {
    # don't print packages or sources that are named default,
    # cause they are only pseudo packages for setting default values
    next if $pkg eq "default";

    printf ("%-${maxlen}s\t\t", $pkg);
    # look if this is a package:
   if (exists $cfg->{'source'}{$pkg}) {
     if (exists $cfg->{'source'}{$pkg}{'description'}) {
       print $cfg->{'source'}{$pkg}{'description'};
     }
   } else {
     print "not existing source !!";
   }
    print "\n";
  }

  if (scalar(@pkglist) > 0) {
    print "\nPackages:\n---------------------------------------------------------\n";
  }
  foreach $pkg (sort @pkglist) {
    # don't print packages or sources that are named default,
    # cause they are only pseudo packages for setting default values
    next if $pkg eq "default";
    printf ("%-${maxlen}s\t\t", $pkg);
    # look if this is a package:
   if (exists $cfg->{'package'}{$pkg}) {
     if (exists $cfg->{'package'}{$pkg}{'description'}) {
       print $cfg->{'package'}{$pkg}{'description'};
 
  }
   } else {
     print "not existing package!!";
   }
    print "\n";
  }

  print "\n";

}

1;
