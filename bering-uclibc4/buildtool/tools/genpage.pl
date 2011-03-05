#! /usr/bin/perl -w

use strict;
use warnings;
no warnings "recursion";

# INCLUDES
use Date::Parse;
use Date::Format;
use Getopt::Long;
use Config::General;
use Data::Dumper;
use File::Spec;
use File::Path;
use File::Temp;
use Carp;
use Symbol;
use Time::Local;
use Text::Wrap;

my $tempDir;
my $GITINFO = {};
my $verbose = 0;
my $onlyfirstline=0;


sub trim($) {
	my ($string_to_trim) = @_;

	return unless defined($string_to_trim);

	$string_to_trim=~ s/^\s+//;
	$string_to_trim=~ s/\s+$//;

	return($string_to_trim);
}


sub getRealPackageName($;$);
sub getRealPackageName($;$) {
	my ($directory, $extension) = @_;

	$extension = "conf" unless defined($extension);
	# find the file to read
	# Get the contents.
	my $dirFH = Symbol::gensym();
	my $name;


	if (! opendir($dirFH, $directory)) {
		confess("Can't opendir (" . $directory . "). $!");
	}

	my @files = readdir($dirFH);
	closedir($dirFH);

	foreach my $file (@files) {
		next if $file eq '.' || $file eq '..';
		next if (-d File::Spec->catdir($directory, $file));

		if ($file =~ /^([^\.]*)\.$extension$/) {
			$name = $1;
			last;
		}
	}


	close($dirFH);
	if (!defined($name)) {
		return(getRealPackageName($directory, "conf")) if ($extension eq "list" ) ;
		return(getRealPackageName($directory, "help")) if ($extension eq "conf" ) ;
		return(getRealPackageName($directory, "version")) if ($extension eq "help" ) ;
		return(getRealPackageName($directory, "exclude\.list")) if ($extension eq "version" ) ;
		confess("could not find a file to use in $directory to determine the package name for package");
	}
	return $name;

}


sub _parseGITLogFileInfo($) {
	my ($directory) = @_;
	my $p_h_GITInfo = {};
	my $p_h_rawFileInfo = {};

	print STDERR "Getting git log for $directory\n" if $verbose;
	my $h_directory = Symbol::gensym();
	opendir($h_directory, $directory);
	my @files = readdir($h_directory);
	closedir($h_directory);

	foreach my $file (@files) {
		next unless $file =~/^.*\.lrp$/;
		$p_h_rawFileInfo->{$file} = [];
		my $hInputFile     = Symbol::gensym();
		my $pid = open($hInputFile, "cd $directory; git log $file |");
   		
		
		my $line;
		while (defined($line = <$hInputFile>)) {
			last unless $line;
			push(@{$p_h_rawFileInfo->{$file}}, $line);
		}
	}

	foreach my $filename (keys %{$p_h_rawFileInfo}) {
		my $p_h_file = {
				'FILENAME' => $filename,
				'REVISIONS' => []
			};

		my $revisionDelimiterFound =0;
		my $inHeader=1;
		my $p_h_revision = {};
		foreach my $line (@{$p_h_rawFileInfo->{$filename}}) {

			# extract commit id
			if ($line =~ /^commit ([a-f0-9]+)$/) {
				# new revision
				$p_h_revision = {};
				$p_h_revision->{'COMMITID'} = $1;
				push @{$p_h_file->{'REVISIONS'}}, $p_h_revision;
				next;
			}

			# extract author
			if ($line =~ /^Author: (.*)$/) {
				$p_h_revision->{'AUTHOR'} = $1;
				next;
			}
			
			# exctract Date
			if ($line =~ /^Date:\s*(.*)$/) {
				$p_h_revision->{'DATE'} = str2time($1);
				next;
			}
			
			# extract message
			if ($line=~ /^\s+(.*)\s*$/){
				my $extracted = $1;
				# skip empty lines
				if ($extracted !~ /^\s*$/) {
					if (exists($p_h_revision->{'MESSAGE'})) {
						if (!$onlyfirstline) {
							$p_h_revision->{'MESSAGE'} = $p_h_revision->{'MESSAGE'} . "\n" . $extracted;
						}
					} else {
						$p_h_revision->{'MESSAGE'} = $extracted;
					}	
				}
			}
		}

		# save the info
		$p_h_GITInfo->{$filename} = $p_h_file;

	}
	return $p_h_GITInfo;
}

sub getGITInfo($$) {
	my ($directory, $file) = @_;

	$GITINFO->{'WORKING_DIR'} = {} unless exists($GITINFO->{'WORKING_DIR'});
	if (!exists($GITINFO->{'WORKING_DIR'}->{$directory})) {
		$GITINFO->{'WORKING_DIR'}->{$directory} = _parseGITLogFileInfo($directory);
	}

	return $GITINFO->{'WORKING_DIR'}->{$directory}->{$file};
}


# prototype - needed because of the recursion
sub getLrpList($$$$);
sub getLrpList($$$$) {
	my ($current_dir, $p_h_files, $group, $root_dir) = @_;;


	# Get the contents.
	my $dirFH = Symbol::gensym();

	if (! opendir($dirFH, $current_dir)) {
		confess("Can't opendir (" . $current_dir . "). $!");
	}

	my @files = readdir($dirFH);
	closedir($dirFH);

	foreach my $file (@files) {
		next if $file eq '.' || $file eq '..';
		my $filename = File::Spec->catdir($current_dir, $file);


		# only descent into subdirs one level (and only if the directory is called "testing" or "contrib"
		if (-d File::Spec->catdir($current_dir, $file) && ($file eq "testing" || $file eq "contrib") && $current_dir eq $root_dir ) {
			getLrpList(
						$filename,
						$p_h_files,
						$group,
						$root_dir
					);
		} else {

			if ($file =~ /(.*)\.lrp$/) {
				# if this package already exists in the hash, it will be overwritten
				# this way (if we're called in the right order) version-specific packages will
				# override versionless packages (like modules.lrp for example)
				my $package = $1;
				my $filepath=File::Spec->catfile($current_dir, $file);
				$p_h_files->{$filepath} = {
					'PACKAGE'	=> $package,
					'FILENAME'	=> $filename,
					'TYPE'		=> 'FILE',
					'GROUP'		=> $group
					};

				# everything in the "testing" dir gets group "TESTING"
				if ($current_dir =~ /$root_dir\/testing.*$/) {
					$p_h_files->{$filepath}->{'GROUP'} = 'TESTING';
				}

				# everything in the "contrib" dir gets group "CONTRIB"
				if ($current_dir =~ /$root_dir\/contrib.*$/) {
					$p_h_files->{$filepath}->{'GROUP'} = 'CONTRIB';
				}

				$p_h_files->{$filepath}->{'GITINFO'} = getGITInfo($current_dir, $file);

			}
		}
	}
}

sub prepareTempDir()
{
	eval {
		$tempDir = File::Temp::tempdir(
					'PACKAGE_TEMP_XXXX',
					'TMPDIR' => 1
				);
	};
	if ($@ ne '') {
		confess("Unable to create temporary directory. $@");
	}
}

sub cleanTempDir() {
	confess("Temp dir undefined") unless defined($tempDir);
	confess("Will not delete root dir") if File::Spec->canonpath($tempDir) eq File::Spec->rootdir();
	system("rm -rf $tempDir");
	rmdir($tempDir);
}

sub readFile($$) {
	my ($directory, $extension) = @_;
	my $lines = [];
	my $line ;
	my $name;

	# find the file to read
	# Get the contents.
	my $dirFH = Symbol::gensym();

	if (! opendir($dirFH, $directory)) {
		confess("Can't opendir (" . $directory . "). $!");
	}

	my @files = readdir($dirFH);
	closedir($dirFH);

	foreach my $file (@files) {
		next if $file eq '.' || $file eq '..';
		next if (-d File::Spec->catdir($directory, $file));

		if ($file =~ /(.*)\.$extension$/) {
			$name = $file;
			last;
		}
	}


	close($dirFH);

	if (!(defined($name) && $name)) {
		print STDERR "Could not find file with extension $extension in dir $directory\n"

	} else {
		my $hInputFile     = Symbol::gensym();
		open($hInputFile,File::Spec->catfile($directory, $name)) or return [];


		$line = '';
		while($line = <$hInputFile>){
			# stop on the first blank line
			last if ($line =~ /^\s*$/ );

			# trim trailing spaces
			$line =~ s/\s+$/\n/;
			push(@{$lines},$line);

		}
		close($hInputFile);
	}
	return $lines;

}

=head2 escape($$$)

 from XML::Generator
 escape the provided string to conform to HTML or XML standards


=cut

sub escape($;$$) {
	my ($argument, $quoteFlag, $alwaysFlag)= @_;

	return unless defined $argument;

	$quoteFlag = 1 unless defined($quoteFlag) ;
	$alwaysFlag = 1 unless defined($alwaysFlag);

	if ($alwaysFlag) {
		$argument =~ s/&/&amp;/g;  # & first of course
		$argument =~ s/</&lt;/g;
		$argument =~ s/>/&gt;/g;
		$argument =~ s/"/&quot;/g if $quoteFlag; # "
	} else {
		$argument =~ s/([^\\]|^)&/$1&amp;/g;
		$argument =~ s/\\&/&/g;
		$argument =~ s/([^\\]|^)</$1&lt;/g;
		$argument =~ s/\\</</g;
		$argument =~ s/([^\\]|^)>/$1&gt;/g;
		$argument =~ s/\\>/>/g;
		$argument =~ s/([^\\]|^)"/$1&quot;/g if $quoteFlag;	# "
		$argument =~ s/\\"/"/g if $quoteFlag;				# "
	}

	return($argument);
}


sub replaceLinks($) {
	my ($string) = @_;

	$string =~ s/(http:\/\/[^\s<\(\),]*)/<a href="$1">$1<\/a>/ig;
	$string =~ s/(https:\/\/[^\s<\(\),]*)/<a href="$1">$1<\/a>/ig;
	$string =~ s/(ftp:\/\/[^\s<\(\),]*)/<a href="$1">$1<\/a>/ig;

	return($string);
}

sub handleKeyword($$$$$$$$$$) {
	my ($keyword, $line, $link, $p_h_files,$package,$package_filepath, $p_h_template,$p_h_noversion_config,$p_h_testing, $p_h_contrib) = @_;

	if ($line =~ /(.*)(\s*$keyword*\s+)([^<]*)(.*)/ig)  {
		my $prefix = $1;
		my $newLine = $prefix . $2;
		my $pkgs = $3;
		my $suffix = $4;
		my $tmpLink = $link;

		if ($prefix =~ /<br \/>$/) {
			foreach my $dependency (split(/\s+/,$pkgs)) {
				my $tmpLink = $link;
				if ($dependency =~ /(.*)\.lrp/ig) {
					#$dependency =~ /(.*)\.lrp/ig;
					$dependency=$1;
				}

				my $found_filepath;
				# Find out if we need to link to a released or testing package
				# first, find a package that is in the same "GROUP" as the current package
				foreach my $tmp_filepath (keys %{$p_h_files}) {
					next unless $p_h_files->{$tmp_filepath}->{'PACKAGE'} eq $dependency;
					next unless $p_h_files->{$tmp_filepath}->{'GROUP'} eq  $p_h_files->{$package_filepath}->{'GROUP'};

					$found_filepath = $tmp_filepath;
				}

				# if that didn't return anything, we use _any_ package
				# note, it should _never_ happen that the same package is in the
				# VERSION and NOVERSION group !!!
				if (!defined($found_filepath)) {
					foreach my $tmp_filepath (keys %{$p_h_files}) {
						next unless $p_h_files->{$tmp_filepath}->{'PACKAGE'} eq $dependency;
						$found_filepath = $tmp_filepath;
					}
				}

				if (!defined($found_filepath)) {
					print STDERR "Warning: did not find dependency \"$dependency\" for package $package!\n";
				} else {
					if ($p_h_files->{$found_filepath}->{'GROUP'} eq 'VERSION'){
						$tmpLink = $p_h_template->{'link'};
					} else {
						if ($p_h_files->{$found_filepath}->{'GROUP'} eq 'NOVERSION'){
						$tmpLink = $p_h_noversion_config->{'link'};
						} else {
							if ($p_h_files->{$found_filepath}->{'GROUP'} eq 'TESTING'){
								$tmpLink = $p_h_testing->{'link'};
							} else {

								if ($p_h_files->{$found_filepath}->{'GROUP'} eq 'CONTRIB'){
									$tmpLink = $p_h_contrib->{'link'};
								}
							}
						}
					}
				}
				$tmpLink =~ s/__PACKAGE_NAME__/$dependency/ig;
				if (!defined($found_filepath)) {
					$newLine .= "$dependency ";
				} else {
					$newLine .= qq{<a href="$tmpLink">$dependency.lrp</a> };
				}
			}
			$line = $newLine . $suffix;
		}
	}
	return $line
}

sub do_linebreak($) {
	my ($text) = @_;
	# replace all <br /> by with <p> blocks
	$text = "<p>" . join("</p>\n<p>", split(/\n/, $text)) . "</p>";
	
	return($text);	
}


my $Usage = qq{$0: --version=uclibc-version
      [--directory=directory_of_lrps]
      [--mergenoversion]
      [--excludetesting]
      [--excludecontrib]
      [--noversiondir=dir]
      [--test]
      [--verbose]
      [--nogrouping]
      [--changelog=filename]
      [--configfile=filename]
      [--outputfile=filename]
      [--alwaysshowdate]
      [--onlyfirstline]

 version        Version of uclibc to use (e.g 0.9.30.3)
 directory      Directory where the lrps reside (overrides setting in config)
 mergenoversion If supplied the pagages found in "noversiondir" will also
                be added to the page
 noversiondir   directory of the packages that are not version-specific
 excludetesting If supplied, packages from the testing subdirs will be skipped
 excludecontrib If supplied, packages from the contrib subdirs will be skipped
 test           Print a whole html page (including HTML header and footer)
                good for testing in a browser locally
 verbose        Print extra info to STDERR
 nogrouping     Do not group packages together, even if they have identical help text
 changelog      Save a text-version of the changelog to the specified file
 configfile     Configuration file to use (default: packages.conf)
 outputfile     File to write the generated html to (default: stdout)
 onlyfirstline  If specified, only the first line of the git changelog will be used
 alwaysshowdate If specified, the date in the changelog will always be displayed (even if it is the same as in the line above)

};

my $options = {};
my $sourceDir;
my $p_h_template;
my $head;
my $foot;
my $test_only = 0;
my $disable_grouping = 0;
my $excludetesting = 0;
my $excludecontrib = 0;
my $alwaysshowdate=0;


Getopt::Long::GetOptions(	$options,
							'version=s',
							'directory=s',
							'noversiondir=s',
							'test',
							'mergenoversion',
							'excludetesting',
							'excludecontrib',
							'verbose',
							'nogrouping',
							'changelog=s',
							'configfile=s',
							'outputfile=s',
							'onlyfirstline',
							'alwaysshowdate',
							)	or die $Usage;

die $Usage unless exists($options->{'version'});
$sourceDir = $options->{'directory'} if exists($options->{'directory'});

$test_only=1 if exists($options->{'test'});
$verbose=1 if exists($options->{'verbose'});
$disable_grouping=1 if exists($options->{'nogrouping'});
$onlyfirstline=1 if exists($options->{'onlyfirstline'});
$alwaysshowdate=1 if exists($options->{'alwaysshowdate'});
$excludetesting=1 if exists($options->{'excludetesting'}) ;
$excludecontrib=1 if exists($options->{'excludecontrib'}) ;

my $configFile = 'packages.conf';
$configFile=$options->{'configfile'} if exists($options->{'configfile'}) ;

my $outputFileName = undef;
$outputFileName=$options->{'outputfile'} if exists($options->{'outputfile'}) ;


my $changelogFile = undef;
$changelogFile = $options->{'changelog'} if exists($options->{'changelog'}) ;

# MAIN
#fetch the buildtool config
my $packageConfig= new Config::General(
			"-ConfigFile" => $configFile,
			"-LowerCaseNames" => 1,
			"-ExtendedAccess"=> 1
		);

$packageConfig = $packageConfig->value('config');

$head = $packageConfig->{'body_head'} if exists($packageConfig->{'body_head'});
$foot = $packageConfig->{'body_foot'} if exists($packageConfig->{'body_foot'});

# set up a default of 30 days, if max_age_for_changelog was not specified in the config
$packageConfig->{'max_age_for_changelog'} = 30 unless exists $packageConfig->{'max_age_for_changelog'};
my $p_h_packages_to_skip = {};
$packageConfig->{'packages_to_skip'} = '' unless exists($packageConfig->{'packages_to_skip'});
foreach my $pkg (split(/,/,$packageConfig->{'packages_to_skip'})){
	$p_h_packages_to_skip->{$pkg} = 1;
}

my $p_h_testing;
foreach my $item (@{$packageConfig->{'package_template'}}) {
	$p_h_testing = $item if $item->{'version'} eq $options->{'version'} . "_testing";

	next unless $item->{'version'} eq $options->{'version'};
	$p_h_template= $item;
	$p_h_template->{'source'} = $sourceDir if defined($sourceDir);
}

my $p_h_contrib;
foreach my $item (@{$packageConfig->{'package_template'}}) {
	$p_h_contrib = $item if $item->{'version'} eq $options->{'version'} . "_contrib";

	next unless $item->{'version'} eq $options->{'version'};
	$p_h_template= $item;
	$p_h_template->{'source'} = $sourceDir if defined($sourceDir);
}


die "Version " . $options->{'version'} ." not found in packages.conf" unless defined($p_h_template);

if (!defined($p_h_testing)) {
	print STDERR $options->{'version'} . "_testing not found in packages.conf - not generating a 'testing' section";
	$excludetesting = 1;
}

if (!defined($p_h_contrib)) {
	print STDERR $options->{'version'} . "_contrib not found in packages.conf - not generating a 'contrib' section";
	$excludecontrib = 1;
}

my $testingLink;
my $testing_head;
my $testing_foot;

my $contribLink;
my $contrib_head;
my $contrib_foot;

if (!$excludetesting) {
	die "No config for link in section " .$options->{'version'}."_testing of the config!" unless exists($p_h_testing->{'link'});
	$testingLink = $p_h_testing->{'link'};

	$testing_head = $packageConfig->{'body_head'} if exists($packageConfig->{'body_head'});
	$testing_foot = $packageConfig->{'body_foot'} if exists($packageConfig->{'body_foot'});

	# overwrite version specific settings, if they were specified
	$testing_head = $p_h_testing->{'body_head'} if exists($p_h_testing->{'body_head'});
	$testing_foot = $p_h_testing->{'body_foot'} if  exists($p_h_testing->{'body_foot'});
}

if (!$excludecontrib) {
	die "No config for link in section " .$options->{'version'}."_contrib of the config!" unless exists($p_h_contrib->{'link'});
	$contribLink = $p_h_contrib->{'link'};

	$contrib_head = $packageConfig->{'body_head'} if exists($packageConfig->{'body_head'});
	$contrib_foot = $packageConfig->{'body_foot'} if exists($packageConfig->{'body_foot'});

	# overwrite version specific settings, if they were specified
	$contrib_head = $p_h_contrib->{'body_head'} if  exists($p_h_contrib->{'body_head'});
	$contrib_foot = $p_h_contrib->{'body_foot'} if  exists($p_h_contrib->{'body_foot'});
}

if (exists($p_h_template->{'packages_to_skip'}) ){
	foreach my $pkg (split(/,/,$p_h_template->{'packages_to_skip'})){
		$p_h_packages_to_skip->{$pkg} = 1;
	}
}



my $p_h_noversion_config;
my $noversionLink;

if (exists($options->{'mergenoversion'})) {
	$p_h_noversion_config = $packageConfig->{'no_version'};


	$noversionLink = $p_h_noversion_config->{'link'};
	die "No config for link in section no_version of the config!" unless exists($p_h_noversion_config->{'link'});

	# Overwrite the default from the config
	$p_h_noversion_config->{'source'} = $options->{'noversiondir'} if exists($options->{'noversiondir'});
	die "No directory for no_version packages supplied!" unless exists($p_h_noversion_config->{'source'}) && $p_h_noversion_config->{'source'};

}

# overwrite version specific settings, if they were specified
$head = $p_h_template->{'body_head'} if exists($p_h_template->{'body_head'});
$foot = $p_h_template->{'body_foot'} if exists($p_h_template->{'body_foot'});

my $p_h_files = {};

print STDERR "Fetching file-list and GIT info: \n" if $verbose;

if (exists($options->{'mergenoversion'})) {
	getLrpList($p_h_noversion_config->{'source'}, $p_h_files, "NOVERSION",$p_h_noversion_config->{'source'});
}
getLrpList($p_h_template->{'source'}, $p_h_files, "VERSION",$p_h_template->{'source'});

my $p_h_packages = {
		'PACKAGES' => {},
		'GROUPS' => {},
	};

my $changelog = {};
my $counter = 0;
my $lines = [];

my $page_head = $packageConfig->{'page_head'} if exists($packageConfig->{'page_head'});
my $page_foot = $packageConfig->{'page_foot'} if exists($packageConfig->{'page_foot'});
die "no config for 'page_head'" unless defined($page_head);
die "no config for 'page_foot'" unless defined($page_foot);

foreach my $filepath (sort {
							$p_h_files->{$a}->{'PACKAGE'} cmp $p_h_files->{$b}->{'PACKAGE'}
						 } keys %{$p_h_files}) {

	my $package = $p_h_files->{$filepath}->{'PACKAGE'};
	$p_h_files->{$filepath}->{'LINK_NAME'} = "PKG_".$counter++;

	foreach my $revision (@{$p_h_files->{$filepath}->{'GITINFO'}->{'REVISIONS'}}) {
		my $rev_date = $revision->{'DATE'};
		
		$revision->{'FILENAME'} = $p_h_files->{$filepath}->{'GITINFO'}->{'FILENAME'};
		$revision->{'AUTHOR'} = $revision->{'AUTHOR'};		
		$revision->{'LINK_NAME'} = $p_h_files->{$filepath}->{'LINK_NAME'};		
		
		# save the cvs info for the changelog
		$changelog->{$rev_date} = [] unless exists($changelog->{$rev_date});
		push(@{$changelog->{$rev_date}}, $revision);
	}

	# skip initrd, initrd_ide and so on
	if (exists($p_h_packages_to_skip->{$package})) {
		print STDERR "skipping $package\n" if $verbose;
		next
	}
	prepareTempDir();

	my $p_h_config;
	if ($p_h_files->{$filepath}->{'GROUP'} eq 'VERSION'){
		$p_h_config = $p_h_template;
	} else {
		if ($p_h_files->{$filepath}->{'GROUP'} eq 'NOVERSION'){
		 $p_h_config = $p_h_noversion_config;
		} else {
			if ($p_h_files->{$filepath}->{'GROUP'} eq 'TESTING'){
				$p_h_config = $p_h_testing;
			} else {
				if ($p_h_files->{$filepath}->{'GROUP'} eq 'CONTRIB'){
					$p_h_config = $p_h_contrib;
				}
			}

		}
	}

	#print STDERR "processing $package\n" if $verbose;

	my $item_head = $packageConfig->{'item_head'} if exists($packageConfig->{'item_head'});
	my $item_link = $packageConfig->{'item_link'} if exists($packageConfig->{'item_link'});
	my $item_body = $packageConfig->{'item_body'} if exists($packageConfig->{'item_body'});
	my $item_foot = $packageConfig->{'item_foot'} if exists($packageConfig->{'item_foot'});


	$item_head = $p_h_config->{'item_head'} if exists($p_h_config->{'item_head'});
	$item_link = $p_h_config->{'item_link'} if exists($p_h_config->{'item_link'});
	$item_body = $p_h_config->{'item_body'} if exists($p_h_config->{'item_body'});
	$item_foot = $p_h_config->{'item_foot'} if exists($p_h_config->{'item_foot'});

	die "no config for 'item_head'" unless defined($item_head) ;
	die "no config for 'item_link'" unless defined($item_link);
	die "no config for 'item_body'" unless defined($item_body);
	die "no config for 'item_foot'" unless defined($item_foot);

	my $file = $p_h_files->{$filepath}->{'FILENAME'};

	my $link;
	my $p_h_overrides={};

	$link = $p_h_config->{'link'};
	$p_h_overrides = $p_h_config->{'overrides'} if exists($p_h_config->{'overrides'});

	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	$atime,$mtime,$ctime,$blksize,$blocks)			= stat($filepath);
	# make sure we don't prink a size of 0
	$size=1024 if ($size<1024);
	$size = sprintf("%d", ($size+512)/1024);

	my $command = "tar xvfz $filepath -C $tempDir 2>&1 > /dev/null ";
	my $realPackageName = $package;
	#print STDERR "$command\n";
	if (!exists($p_h_overrides->{$package}->{'help'}) || !exists($p_h_overrides->{$package}->{'version'})) {
		my $retVal = system($command);
		if ($retVal>>8 != 0 ) {
			cleanTempDir();
			confess("Extracting $file failed. $!");
		}

		$realPackageName = getRealPackageName(File::Spec->catfile($tempDir, "var", "lib","lrpkg"));
	}

	my $p_l_packageVersion ;
	my $p_l_packageHelp ;

	if (	exists($p_h_overrides->{$package}) &&
			exists($p_h_overrides->{$package}->{'help'})) {
		$p_l_packageHelp = [split(/\n/,$p_h_overrides->{$package}->{'help'})];
	} else {

		$p_l_packageHelp = readFile(File::Spec->catfile($tempDir, "var", "lib","lrpkg"),"help");
	}

	if ( 	exists($p_h_overrides->{$package}) &&
			exists($p_h_overrides->{$package}->{'version'})) {
		$p_l_packageVersion = [split(/\n/,$p_h_overrides->{$package}->{'version'})];
	} else {
		$p_l_packageVersion = readFile(File::Spec->catdir($tempDir, "var", "lib","lrpkg"),"version");
	}
	my $packageHelp = '';
	my $packageVersion = '';
	foreach my $line (@{$p_l_packageHelp}) {
		#print STDERR $line . "\n";
		$line = escape($line);
		$line =~ s/(LEAF package by)/<br \/>$1/igs;
		$line =~ s/^(.{1,55})$/$1 <br \/>/ig;
#		$line =~ s/^\s+(.*)(?<!<br \/>)$/$1 <br \/>/ig;

		# if the line ends with a "." of ":", we treat the CR as a new paragraph
		$line =~ s/^(.*\.)$/$1<br \/>/ig;
		$line =~ s/^(.*:)$/$1<br \/>/ig;

		# if the line starts with a capital letter, treat it as a new paragraph
		$line =~ s/^([A-Z][a-z])/<br \/>$1/g;

		$line = replaceLinks($line);

		# pretend what's followed by a configured keyword (like "Requires:") is a list of links
		# for this to work, the keyword needs to be followed by a whitespace delimited list of package names
		# (with or without the ".lrp").
		foreach my $keyword (@{$packageConfig->{'keywords'}->{'keyword'}}) {
			$line = handleKeyword(	$keyword,
									$line,
									$link,
									$p_h_files,
									$package,
									$filepath,
									$p_h_template,
									$p_h_noversion_config,
									$p_h_testing,
									$p_h_contrib);
		}
		$packageHelp.=$line;
	}
	
	# trim trailing spaces
	$packageHelp =~ s/\s*$//;

	if ($realPackageName ne $package) {
		my $warning = $packageConfig->{'rename_warning'};
		$warning  =~ s/__NEW_PACKAGE_NAME__/$realPackageName/ig;
		$packageHelp.="<br />\n" . $warning;
	}

	$packageHelp = $packageConfig->{'no_help_text'} if ($packageHelp eq '');

	# make sure that "Requires: packagelist" "See: URL" and "Homepage: URL" appear in their own line
	$packageHelp =~ s/\nRequires:/<br \/>\nRequires:/igs;
	$packageHelp =~ s/\nSee:/<br \/>\nSee:/igs;
	$packageHelp =~ s/\nHomepage:/<br \/>\nHomepage:/igs;


	# replace "LRP package" with "LEAF package"
	$packageHelp =~ s/lrp (package)/LEAF $1/ig;

	foreach my $line (@{$p_l_packageVersion}) {
		#print STDERR $line . "\n";
		$line = escape($line);
		$packageVersion.=$line;
	}
	$packageVersion = replaceLinks($packageVersion);

	# replace extra occurrences of "version" at the beginning of the packageVersion string
	$packageVersion =~ s/^\s*version[:\s]*//ig;

	# replace empty version strings with "n/a"
	$packageVersion = $packageConfig->{'no_version_text'} if $packageVersion =~ /^\s*$/;


	$link =~ s/__PACKAGE_NAME__/$package/ig;
	$link =~ s/__SIZE__/$size/ig;
	$link =~ s/__HELP__/$packageHelp/ig;
	$link =~ s/__VERSION__/$packageVersion/ig;
	$link =~ s/__ANCHOR__/$p_h_files->{$filepath}->{'LINK_NAME'}/ig;


	$item_head =~ s/__LINK__/$link/ig;
	$item_head=~ s/__SIZE__/$size/ig;
	$item_head=~ s/__PACKAGE_NAME__/$package/ig;
	$item_head=~ s/__HELP__/$packageHelp/ig;
	$item_head=~ s/__ANCHOR__/$p_h_files->{$filepath}->{'LINK_NAME'}/ig;


	$item_link=~ s/__LINK__/$link/ig;
	$item_link=~ s/__PACKAGE_NAME__/$package/ig;
	$item_link=~ s/__SIZE__/$size/ig;
	$item_link=~ s/__HELP__/$packageHelp/ig;
	$item_link=~ s/__ANCHOR__/$p_h_files->{$filepath}->{'LINK_NAME'}/ig;


	$item_body =~ s/__LINK__/$link/ig;
	$item_body=~ s/__PACKAGE_NAME__/$package/ig;
	$item_body=~ s/__SIZE__/$size/ig;
	$item_body=~ s/__HELP__/$packageHelp/ig;
	$item_body=~ s/__ANCHOR__/$p_h_files->{$filepath}->{'LINK_NAME'}/ig;


	$item_foot =~ s/__LINK__/$link/ig;
	$item_foot=~ s/__PACKAGE_NAME__/$package/ig;
	$item_foot=~ s/__SIZE__/$size/ig;
	$item_foot=~ s/__HELP__/$packageHelp/ig;
	$item_foot=~ s/__ANCHOR__/$p_h_files->{$filepath}->{'LINK_NAME'}/ig;

	$p_h_packages->{'GROUPS'}->{$packageHelp} = {} unless exists($p_h_packages->{'GROUPS'}->{$packageHelp});
	$p_h_packages->{'GROUPS'}->{$packageHelp}->{$filepath} = 1;
	$p_h_packages->{'PACKAGES'}->{$filepath} = {
			'NAME' 		=> $package,
			'HELP'		=> $packageHelp,
			'VERSION'	=> $packageVersion,
			'LINK'		=> $link,
			'ITEM_HEAD'	=> $item_head,
			'ITEM_LINK'	=> $item_link,
			'ITEM_BODY'	=> $item_body,
			'ITEM_FOOT'	=> $item_foot,
			'GROUP'		=> $p_h_files->{$filepath}->{'GROUP'},
		};



	cleanTempDir();


}

my $first_package_in_group;
# find packages that have a common description
foreach my $hashkey (keys %{$p_h_packages->{'GROUPS'}}) {
	$first_package_in_group=undef;
	if (!$disable_grouping && $hashkey ne $packageConfig->{'no_help_text'}) {
		foreach my $filepath (sort keys %{$p_h_packages->{'GROUPS'}->{$hashkey}}) {
			if (defined($first_package_in_group)) {
				if ($p_h_packages->{'PACKAGES'}->{$filepath}->{'GROUP'} eq $p_h_packages->{'PACKAGES'}->{$first_package_in_group}->{'GROUP'}) {


					#$p_h_packages->{'PACKAGES'}->{$first_package_in_group}->{'ITEM_LINK'} .= ", " . $p_h_packages->{'PACKAGES'}->{$filepath}->{'ITEM_LINK'};
					$p_h_packages->{'PACKAGES'}->{$first_package_in_group}->{'ITEM_LINK'} .=  $p_h_packages->{'PACKAGES'}->{$filepath}->{'ITEM_LINK'};
					$p_h_packages->{'PACKAGES'}->{$first_package_in_group}->{'VERSION'} = $packageConfig->{'no_version_text'} if ($p_h_packages->{'PACKAGES'}->{$filepath}->{'VERSION'} ne $p_h_packages->{'PACKAGES'}->{$first_package_in_group}->{'VERSION'});

					delete($p_h_packages->{'PACKAGES'}->{$filepath});
				}
			} else {
				# no group or first item of a group
				$first_package_in_group = $filepath;
			}
		}
	}
}

my $testing_lines=[];
my $contrib_lines=[];
foreach my $filepath (sort {
			$p_h_packages->{'PACKAGES'}->{$a}->{'NAME'} cmp $p_h_packages->{'PACKAGES'}->{$b}->{'NAME'}
		 } keys %{$p_h_packages->{'PACKAGES'}}) {

	my $item = $p_h_packages->{'PACKAGES'}->{$filepath}->{'ITEM_BODY'} .
				$p_h_packages->{'PACKAGES'}->{$filepath}->{'ITEM_FOOT'};


	$item=~ s/__VERSION__/$p_h_packages->{'PACKAGES'}->{$filepath}->{'VERSION'}/ig;

	# Clean up unnecessary <br /> tags
	$item =~ s/(<br \/>\s*)+/<br \/>/igs;
	$item =~ s/(<p>\s*<br \/>)+/<p>/igs;

	# format the code, to make it more readable
	$item =~ s/\s*<br \/>/<br \/>\n/igs;
	$item .="\n";

	# replace all <br /> by with <p> blocks;
	my @paras = split(/<br \/>/, $item);
	
	$item = $p_h_packages->{'PACKAGES'}->{$filepath}->{'ITEM_HEAD'}  .
		$p_h_packages->{'PACKAGES'}->{$filepath}->{'ITEM_LINK'} .
		join("</p>\n<p>", @paras);
	
	# remove empty <p> blocks
	$item =~ s/<p>\s*<\/p>//igs;
	$item =~ s/<p>\s*<p>/<p>/igs;

	# clean up formatting
	$item =~ s/<p>\n/<p>/igs;
	$item =~ s/\s+<p>/<p>/igs;

	if ($p_h_packages->{'PACKAGES'}->{$filepath}->{'GROUP'} eq 'TESTING') {
		push(@{$testing_lines},$item);
		next;
	}


	if ($p_h_packages->{'PACKAGES'}->{$filepath}->{'GROUP'} eq 'CONTRIB') {
		push(@{$contrib_lines},$item);
		next;
	}

	push(@{$lines},$item);

}

# add package numbers
my $pkgCounter = 1;
my $tmpLines=[];
foreach my $line (@{$lines}) {
	
	while ($line =~ s/__PACKAGE_NUMBER__/$pkgCounter/) {
		$pkgCounter++;
	}
	push(@{$tmpLines},$line);
}
$lines = $tmpLines;

$tmpLines = [];
$pkgCounter=1 if $packageConfig->{'reset_counter'};

foreach my $line (@{$testing_lines}) {
	
	while ($line =~ s/__PACKAGE_NUMBER__/$pkgCounter/) {
		$pkgCounter++;
	}
	push(@{$tmpLines},$line);
}
$testing_lines = $tmpLines;

$tmpLines = [];
$pkgCounter=1 if $packageConfig->{'reset_counter'};
foreach my $line (@{$contrib_lines}) {
	
	while ($line =~ s/__PACKAGE_NUMBER__/$pkgCounter/) {
		$pkgCounter++;
	}
	push(@{$tmpLines},$line);
}
$contrib_lines = $tmpLines;



my $hOutputHandle = Symbol::gensym();
if (defined($outputFileName)) {
	
	if (!open($hOutputHandle, ">$outputFileName")) {
		die "Can't open output file $outputFileName\n$!\n";
	}

} else {
	if (!open($hOutputHandle,">-")) {
			die "Can't open STDOUT\n$!\n";
	}
}

		 
print STDERR "Writing to $outputFileName\n" if defined $outputFileName;
print $hOutputHandle qq{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head><title>Packages 4.x - Bering uClibc</title></head>
<body> } if $test_only;

print $hOutputHandle $page_head . $head . join('', @{$lines}) . $foot . "\n";

if (scalar(@{$testing_lines})>0) {
	print $hOutputHandle $testing_head . join('', @{$testing_lines}) . $testing_foot . "\n";
}


if (scalar(@{$contrib_lines})>0) {
	print $hOutputHandle $contrib_head . join('', @{$contrib_lines}) . $contrib_foot . "\n";
}

print $hOutputHandle $packageConfig->{'changelog_head'};
# print the changelog

my ($sec,$min,$hour,$mday,$mon,$nyear,$wday,$yday) = gmtime(time);

my $textBasedChangelog = [];
my $now = timelocal(0, 0, 0, $mday, $mon, $nyear+1900);
my $lastDate='';
foreach my $date (reverse sort keys %{$changelog}) {
	next unless defined($date) && $date;
	if ($now-$date >$packageConfig->{'max_age_for_changelog'}*60*60*24 ) {
		next;
	}
	foreach my $item (@{$changelog->{$date}}) {
		my $textBasedChangelogItem = [];
		my $formattedDate = time2str("%Y-%m-%d", $date, "UTC");
		# save the info for the plain-text changelog
		if ($alwaysshowdate) {
			push(@{$textBasedChangelog}, [
					$formattedDate,
					$item->{'FILENAME'},
					$item->{'MESSAGE'} ]
			);
			
		} else {
			push(@{$textBasedChangelog}, [
					$lastDate eq $formattedDate?'':$formattedDate,
					$item->{'FILENAME'},
					$item->{'MESSAGE'} ]
			);
			
		}

		print $hOutputHandle '<tr><td>';
		
		if (!$alwaysshowdate && $lastDate eq $formattedDate) {
			print $hOutputHandle "&nbsp;";
		} else {
			print $hOutputHandle $formattedDate;
		}
		print $hOutputHandle '</td>';
		print $hOutputHandle '<td><a href="#' . $item->{'LINK_NAME'} . '">' . $item->{'FILENAME'} . '</a></td>';
		print $hOutputHandle '<td>' . do_linebreak(escape($item->{'MESSAGE'})) .'</td>';		
		
		print $hOutputHandle "</tr>\n";

		$lastDate = $formattedDate;
	}

}

print $hOutputHandle $packageConfig->{'changelog_foot'};
print $hOutputHandle $page_foot;
print $hOutputHandle "</body></html>\n" if $test_only;


if (defined($changelogFile)) {
	my $hOutputFile     = Symbol::gensym();
	if (!open($hOutputFile, ">$changelogFile")) {
		die "Can't open file $changelogFile\n$!\n";
	}
	
	my $maxDate = 0;
	my $maxPackage = 0;
	
	# calculate the max length of each column
	foreach my $textBasedChangelogItem (@{$textBasedChangelog}) {
		my ($date, $package, $message) = @{$textBasedChangelogItem};
		$maxDate = (length($date)) if length($date)>$maxDate;
		$maxPackage = (length($package)) if length($package)>$maxPackage;
	}
	
	my $formatString = "%-${maxPackage}s %s" ;
	my $first=1;
	$Text::Wrap::columns = 72;
	$Text::Wrap::unexpand=0;
	
	foreach my $textBasedChangelogItem (@{$textBasedChangelog}) {
		my ($date, $package, $message) = @{$textBasedChangelogItem};
		
		# generate the line
		my $line = sprintf($formatString, $package,$message);
		
		# calculate how much we have to indent the wrapped lines
		my $subsequentTab = sprintf($formatString, '','');
		
		# print a newline before a date, unless it's the first line
		print $hOutputFile "\n" if !($first || $date eq '');
		print $hOutputFile $date unless $date eq '';
		
		# print the wrapped message
		print $hOutputFile join("",wrap('', $subsequentTab, $line)) . "\n";
		$first=0;
	}
	close $hOutputFile;	
}

close $hOutputHandle;
exit;

__END__


