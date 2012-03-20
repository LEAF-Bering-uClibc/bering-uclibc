#! /usr/bin/perl -w

# TODO
# * replace GetOpt::Long with GetOpt?
# * additional switch --interactive, that will let the user make changes to files,
#   after everything is assembled, but before list-file and lrp-packed is created
# * move buildtool downhttp and downcvs into classes, add downfile and allow
#   buildpackage to dowload the files it needs


use strict;
use warnings;

# INCLUDES
use Getopt::Long;
use Config::General;
use Data::Dumper;
use File::Spec;
use File::Path;
use File::Temp;
use Carp;

# NON PERL INCLUDES

# DEFINITION OF CONSTANTS

# DEFINITION OF GLOBALS
# uclibc Version
my $version = "0.9.32.1";
# kernel Version
my $kver = qx(cat source/linux/linux*/.config | awk '/Linux/ {print \$3}' | head -n 1);
$kver =~ s/\n//;

# archivers for different package type
my $initrd_pkr="gzip";
my $initrd_ext="gz";
my $genlrp_pkr="gzip";
my $genlrp_unp="gzip";
my $skel_unp="gzip";
#
my $verbose;
my $packager;
my $tmpDir;
my $lrp_owner="root";
my $lrp_group="root";
my $options = {};
my $sourceDir;
my $confDir;
my $stagingDir;
my $packageDir;
my $skelFile;
my $gzipOptions;
my $buildInitrd = 0;
my $initrdImage = 0;
my $mountcmd;
my $sign;
my $passphrase;
my $toolchain;
my $localuser;
my $umountcmd;
my $Usage =
qq{$0: --package=packagename --packager=name [--all|--target=packagefile] [--lrp=filename.lrp] [--verbose] [--sign] [--toolchain toolchainname]
 package   Package to create
 packager  Name of the person who packaged the lrp (used for packagename.help 
           file)
 target    (optional) Target lrp to create (default: packagename)
           needed for packages (like openssh) which create more than one lrp
 lrp       (optional) Existing lrp-file to import config from
 all       (optional) Create all packages defined by packagename
           Default if target is not specified
 verbose   Generate verbose diagnostic output
           Default is off
 sign      (optional) Sign package with gpg signature
           The passphrase has to be set in conf/buildtool.conf 
           Default is off
 toolchain (optional) Build packages generated by the specified toolchain
           Default is toolchain specified in conf/buildtool.conf
};

# DEFINITION OF FUNCTIONS

# getnum($number)
#
# Returns the numeric value represented by the string in $number,
# or undef, if it could not be converted FROM PERLFAQ, Section 4
sub getnum($)  {
	my ($number) = @_;
		use POSIX qw(strtod);
		my $str = $number;
		$str =~ s/^\s+//;
		$str =~ s/\s+$//;
		$! = 0;
		my($num, $unparsed) = strtod($str);
		if (($str eq '') || ($unparsed != 0) || $!) {
			return undef;
		} else {
			return $num;
		}
	}


# isNumeric($number)
#
# Returns wether the specified string can be converted into a number
# FROM PERLFAQ, Section 4
sub isNumeric($) {
	my ($number) = @_;
	return (defined getnum($number));
}

# formatDate($year, $month, $day)
#
# Returns the specified date in ANSI format (YYYY-MM-DD)
sub formatDate($$$) {
	my($year, $month, $day) = @_;

	confess() unless defined($year) && defined($month) && defined($day);
	return(sprintf("%04d-%02d-%02d", $year,$month,$day));
}

# packageHelp($config)
#
# Returns the contents of the .help file of the package
sub packageHelp($) {
	my ($p_h_packageConfig) = @_;

	print "Generating package help\n"  if $verbose;
	my $helpMsg = $p_h_packageConfig->{'help'};
	my @timeArray = localtime();
	my $currentDate = formatDate($timeArray[5]+1900, $timeArray[4]+1,$timeArray[3]);

	# replace tokens, if there are any
	$helpMsg =~ s/__PACKAGER__/$packager/g;
	$helpMsg =~ s/__BUILDDATE__/$currentDate/g;

	return "$helpMsg";
}

# packageList($config, $p_h_files, $target)
#
# Returns the contents of the .list file of the package
sub packageList($$$) {
	my ($p_h_packageConfig, $p_h_files, $target) = @_;

	print "Generating package list\n"  if $verbose;

	my $p_h_allFiles = {};	# hash so we can remove/look up files more easily

	# ugly, but it works for now
	# what's happening here is that we have a hash of
	# filenames (value = FILE)/dirnames (value=DIR)
	# we need to turn those into absolute names, and ignore the directories
	# and then merge it with the list from the config, and then remove the
	# entries that are redundant because either there was a pattern specified
	# in the config, or the config specified a directory (in this case,
	# all files from that directory and its subdirectories are automatically
	# included anyway


	# copy all the files (not the directories) from $p_h_files
	# and turn all filenames into absolute paths
	foreach my $file (keys %{$p_h_files}) {
		next if $p_h_files->{$file} eq 'DIR';
		# turn the filename into an absolute path (if necessary)
		if (!File::Spec->file_name_is_absolute($file)) {
			$file = File::Spec->catfile(File::Spec->rootdir(),$file);
		}

		$p_h_allFiles->{$file} = 1;
	}

	my $p_l_listFiles = [
			File::Spec->catfile(File::Spec->rootdir(), 'var','lib','lrpkg',"$target.*"),
		];

	# fetch all file entries from the config that were specified as "LIST"
	foreach my $p_h_file (@{$p_h_packageConfig->{'contents'}->{'file'}}) {
		my $filename = $p_h_file->{'filename'};
		if (exists($p_h_file->{'type'}->{'LIST'})) {
			# turn the filename into an absolute path (if necessary)
			if (exists($p_h_file->{'type'}->{'DIRECTORY'})) {
				if (!File::Spec->file_name_is_absolute($filename)) {
					$filename = File::Spec->catdir(File::Spec->rootdir(),$filename) . "/";
				}
			} else {
				if (!File::Spec->file_name_is_absolute($filename)) {
					$filename = File::Spec->catfile(File::Spec->rootdir(),$filename);
				}
			}
				
			push(@{$p_l_listFiles},$filename);
		}
	}


	# find  and remove redunant entries in the filter list
	my $p_h_tmpListFiles = {};	
	foreach my $listfile (@{$p_l_listFiles}) {
		$p_h_tmpListFiles->{$listfile} = 1;
	}	
	
	# find redunant entries in the filter list
	foreach my $file (@{$p_l_listFiles}) {
		# turn the filenmask into a regex
		# TODO what about more advanced masks?
		my $regex = $file;
		$regex =~ s/\./\\\./ig;
		$regex =~ s/\*/\.\*/ig;
		# make sure a "+" in the filename doesn't screw up our regex
		$regex =~ s/\+/\\\+/ig;
		

		foreach my $fileToCheck (keys %{$p_h_tmpListFiles}) {
			next if $fileToCheck eq $file;
			# if it matches, we can remove it from the list
			if ($fileToCheck =~ /^$regex/g) {
				print "Removing $fileToCheck from listfile-list\n" if $verbose;
				delete($p_h_tmpListFiles->{$fileToCheck});
			}
		}

	}
	
	$p_l_listFiles = [keys %{$p_h_tmpListFiles}];
	
	# merge $p_h_allFiles and $p_l_listFiles and remove redundancies
	foreach my $file (@{$p_l_listFiles}) {
		# turn the filenmask into a regex
		# TODO what about more advanced masks?
		my $regex = $file;
		$regex =~ s/\./\\\./ig;
		$regex =~ s/\*/\.\*/ig;

		# make sure a "+" in the filename doesn't screw up our regex
		$regex =~ s/\+/\\\+/ig;
		

		foreach my $fileToCheck (keys %{$p_h_allFiles}) {
			# if it matches, we can remove it from the list
			if ($fileToCheck =~ /^$regex/g) {
				print "Removing $fileToCheck from file-list\n" if $verbose;
				delete($p_h_allFiles->{$fileToCheck});
			}
		}

	}

	# remove leading slashes (otherwise, tar will complain while backing up)
	my $p_l_returnFiles = [];
	foreach my $file (sort(@{$p_l_listFiles}, keys %{$p_h_allFiles})) {
		$file =~ s/^\///ig;
		$file='./' if $file eq '';
		push (@{$p_l_returnFiles}, $file);
	}

	return join("\n", sort(@{$p_l_returnFiles}));
}

# packageVersion($config)
#
# Returns the contents of the .version file of the package
sub packageVersion($) {
	my ($p_h_packageConfig) = @_;
	print "Generating package version file\n"  if $verbose;
	return '' if  (!defined($p_h_packageConfig->{'version'}) && !defined($p_h_packageConfig->{'revision'}));
	my $ver = $p_h_packageConfig->{'version'};
	$ver =~ s/__KVER__/$kver/g;
	return $ver . " Rev " . $p_h_packageConfig->{'revision'} . " uClibc $version ";

}

# packageLicense($config)
#
# Returns the name of the .license file link
sub packageLicense($) {
	my ($p_h_packageConfig) = @_;
	print "Generating package license file link\n"  if $verbose;
	return '' if  (!defined($p_h_packageConfig->{'license'}));
	return $p_h_packageConfig->{'license'};
}

# packageConf($config)
#
# Returns a hash of contents of the .conf file(s) of the package
# certain packages (etc for example) can have more tha one .conf file
sub packageConf($) {
	my ($p_h_packageConfig) = @_;

	my $p_h_confFiles = {};

	print "Generating package conf file\n"  if $verbose;
	my $p_l_files = [];

	foreach my $p_h_file (@{$p_h_packageConfig->{'contents'}->{'file'}}) {
		next unless exists($p_h_file->{'type'}->{'CONF'});
		my $filename = $p_h_file->{'filename'};

		$p_h_file->{'conffile'} = $p_h_packageConfig->{'packagename'} unless exists($p_h_file->{'conffile'});
		
		$p_h_confFiles->{$p_h_file->{'conffile'}} = [] unless exists($p_h_confFiles->{$p_h_file->{'conffile'}});
		
		# turn the filename into an absolute path (if necessary)
		if (!File::Spec->file_name_is_absolute($filename)) {
			$filename = File::Spec->catfile(File::Spec->rootdir(),$filename);
		}

		# add the description, if there is one
		if (exists($p_h_file->{'description'}) && $p_h_file->{'description'}) {
			$filename = $filename . "\t" . $p_h_file->{'description'}
		};

		push(@{$p_h_confFiles->{$p_h_file->{'conffile'}}},$filename)
	}

	return $p_h_confFiles;
	#return join("\n", @{$p_l_files});

}

# packageLocal($config)
#
# Returns the contents of the .local file of the package
sub packageLocal($) {
	my ($p_h_packageConfig) = @_;
	my $file ;

	print "Generating package local file\n"  if $verbose;
	my $p_l_files = [];

	foreach my $p_h_file (@{$p_h_packageConfig->{'contents'}->{'file'}}) {

		next unless exists($p_h_file->{'type'}->{'LOCAL'});
		my $filename = $p_h_file->{'filename'};

#		# turn the filename into an absolute path (if necessary)
#		if (!File::Spec->file_name_is_absolute($filename)) {
#			$filename = File::Spec->catfile(File::Spec->rootdir(),$filename);
#		}

#		push(@{$p_l_files},'I ' .$filename)
		push(@{$p_l_files},$filename)
	}



	return join("\n", @{$p_l_files});

}

# packageExclude($config)
#
# Returns the contents of the .exclude.list file of the package
sub packageExclude($) {
	my ($p_h_packageConfig) = @_;
	my $file ;

	print "Generating package exclude.list file\n"  if $verbose;
	my $p_l_files = [];

	foreach my $p_h_file (@{$p_h_packageConfig->{'contents'}->{'file'}}) {

		next unless exists($p_h_file->{'type'}->{'EXCLUDE'});
		my $filename = $p_h_file->{'filename'};

		# turn the filename into an absolute path (if necessary)
		if (!File::Spec->file_name_is_absolute($filename)) {
			$filename = File::Spec->catfile(File::Spec->rootdir(),$filename);
		}

		push(@{$p_l_files},$filename)
	}

	# remove leading slashes (otherwise, tar will complain while backing up)
	my $p_l_returnFiles = [];
	foreach my $file (sort(@{$p_l_files})) {
		$file =~ s/^\///ig;
		push (@{$p_l_returnFiles}, $file);
	}

	return join("\n", @{$p_l_returnFiles});

}

# packageModules($config)
#
# Returns the contents of the .modules file of the package
sub packageModules($) {
	my ($p_h_packageConfig) = @_;
	my $file ;

	print "Generating package local file\n"  if $verbose;
	my $p_m_files = [];

	foreach my $p_h_file (@{$p_h_packageConfig->{'contents'}->{'file'}}) {

		next unless exists($p_h_file->{'type'}->{'MODULE'});
		my $filename = $p_h_file->{'filename'};

#		# turn the filename into an absolute path (if necessary)
#		if (!File::Spec->file_name_is_absolute($filename)) {
#			$filename = File::Spec->catfile(File::Spec->rootdir(),$filename);
#		}

#		push(@{$p_l_files},'I ' .$filename)
		my @arr = split(/\//,$filename);
		push(@{$p_m_files},$arr[-1]);
	}



	return join("\n", @{$p_m_files});

}

sub prepareTempDir($$$)
{
	my ($p_h_package, $package_dir,$p_h_options) = @_;
	
	my $tempDIR;
	print "Setting up temp-dir\n"  if $verbose;

#	if ($buildInitrd) {
#		my $package_filename = $p_h_package->{'packagefilename'};
#		
#		$initrdImage = "$package_dir/$package_filename";
#		my $mountpoint = $p_h_options->{'mountpoint'};	

#		my $initrdsize = exists($p_h_package->{'initrdsize'}) ? $p_h_package->{'initrdsize'} : 1500;	
#		
#		system_exec("dd if=/dev/zero of=$initrdImage bs=1k count=$initrdsize", "failed to create $initrdImage");
#		system_exec($options->{'mkminixfs'} . " $initrdImage 4096","failed to create minix filesystem on $initrdImage");
#		system_exec("$mountcmd -t minix -o loop $initrdImage $mountpoint","failed to mount $initrdImage on $mountpoint");

#		$tempDIR = $mountpoint;
		
#	} else {		
		eval {
			$tempDIR = File::Temp::tempdir(
						'BUILDTOOL_STAGING_XXXX',
						'TMPDIR' => 1
					);
		};
		if ($@ ne '') {
			confess("Unable to create temporary directory. $@");
		}
#	}
	return($tempDIR);
}

sub cleanTempDir() {
	print "Cleaning up dir $tmpDir\n" if $verbose;

#	if ($buildInitrd) {
#		if ($initrdImage) {
#			system_exec("$umountcmd $tmpDir","failed to unmount $tmpDir/",1);
#			system_exec("rm $initrdImage",,1);
#			$initrdImage = 0;
#		}

#	} else  {
		confess("Temp dir undefined") unless defined($tmpDir);
		confess("Will not delete root dir") if File::Spec->canonpath($tmpDir) eq File::Spec->rootdir();
		system("rm -rf $tmpDir");
		rmdir($tmpDir);
#	}
}

sub system_exec($;$$) {
	my ($command, $error_message, $no_cleanup) = @_;

	$no_cleanup = 0 unless defined($no_cleanup);
	
	$error_message = "$command failed " unless defined($error_message);

	print "executing $command\n" if $verbose;
	
	my $retVal = system($command);
	if ( $retVal>>8 != 0 ) {
			cleanTempDir() unless $no_cleanup;
			confess("$error_message $!");
	}
	
}

sub copySkelFileToPackageStaging($$) {
	my ($skel_file, $source_dir) = @_;

	print "Extracting skeleton\n"  if $verbose;

	
	my $skelFile = File::Spec->catfile($source_dir, $skel_file);

	system_exec("cd $tmpDir ; $skel_unp -c -d $skelFile | tar -xvf -  2>&1 > /dev/null","Extracting skel-file failed");
}

sub createDirUnlessItExists($$) {
	my ($path,$p_h_package) = @_;


	while (!(-e $path)) {
		print "Creating dir $path\n"  if $verbose;
		my @dirs = File::Spec->splitdir( $path );

		my $permissions = $p_h_package->{'permissions'}->{'directories'} ;
		# make sure this looks like an octal to perl
		$permissions = '0' . $permissions   unless $permissions =~ /^0/;

		my $dirToCreate = "";
		foreach my $dir (@dirs) {
			$dirToCreate = File::Spec->catdir($dirToCreate, $dir);


			if (!(-e $dirToCreate)) {
				print " Creating dir $dirToCreate\n"  if $verbose;
				mkdir($dirToCreate) or confess("creating dir " . $path . " failed. $!");
				chmod(oct($permissions),$dirToCreate) or die "chmod failed on $dirToCreate";
			}

		}
	}
}

sub createDirectories($$){
		my ($p_h_package, $build_dir) = @_;
		print "Creating directories\n"  if($verbose);

		foreach my $p_h_file (@{$p_h_package->{'contents'}->{'file'}}) {
				my $filename = $p_h_file->{'filename'};

				next unless exists($p_h_file->{'type'}->{'DIRECTORY'});

				my $destination_path = File::Spec->catdir($tmpDir,$filename);

				# create the target directory, if it doesn't exist
				createDirUnlessItExists($destination_path,$p_h_package);

		}

}

sub copyBinariesToPackageStaging($$) {
	my ($p_h_package, $build_dir) = @_;
	print "Copying binaries\n"  if($verbose);

	foreach my $p_h_file (@{$p_h_package->{'contents'}->{'file'}}) {
			my $filename = $p_h_file->{'filename'};

			next unless exists($p_h_file->{'type'}->{'BINARY'});


			my $source_filename = File::Spec->catfile($build_dir,$p_h_file->{'source'});
			$source_filename =~ s/__KVER__/$kver/g;

			my $destination_filename; 
			my $destination_path;

			
			# if the source filename contains "*", the destination file _must_ be a directory
			if ($source_filename =~ /\*/ig) {
				$destination_filename = File::Spec->catdir($tmpDir,$filename);
				$destination_path= $destination_filename;
				
			} else {
				my $volume;
				my $file;
				
				$destination_filename = File::Spec->catdir($tmpDir,$filename);
				($volume,$destination_path,$file) = File::Spec->splitpath( $destination_filename );
			}
			
			$destination_path =~ s/__KVER__/$kver/g;


			# create the target directory, if it doesn't exist
			createDirUnlessItExists($destination_path,$p_h_package);

			# Skip files that are marked as "conf" but already came from the skeleton
			# this way, we don't trash the existing config from the skeleton
			if (exists($p_h_file->{'type'}->{'CONF'}) && ( -e $destination_filename ) ) {
					print "Not overwriting file $destination_filename since it was contained in the skeleton\n" if($verbose);
					next;
			}
			
			system_exec("cp -r $source_filename $destination_filename","Copying file $source_filename failed.");
	}
}

sub createLinksInStaging($$) {
	my ($p_h_package, $build_dir) = @_;
	print "Creating links\n"  if($verbose);

	foreach my $p_h_file (@{$p_h_package->{'contents'}->{'file'}}) {

			my $filename = $p_h_file->{'filename'};

			next unless exists($p_h_file->{'type'}->{'LINK'});

			my $link_target = File::Spec->catfile($tmpDir,$p_h_file->{'target'});
			#$link_target = File::Spec->abs2rel( $link_target, $tmpDir ) ;

			my ($volume1,$targetPath) = File::Spec->splitpath( $link_target );

			# create the target directory, if it doesn't exist
			createDirUnlessItExists($targetPath,$p_h_package);

			my $link_filename = File::Spec->catfile($tmpDir,$filename);
			my ($volume2,$linkPath) = File::Spec->splitpath( $link_filename );

			$link_target = File::Spec->abs2rel( $link_target, $linkPath ) ;

			# special treatement of files that link to the current directory
			$link_target = '.' unless ($link_target);

			#$link_filename = File::Spec->abs2rel( $link_filename, $tmpDir ) ;

			# create the target directory, if it doesn't exist
			createDirUnlessItExists($linkPath,$p_h_package);


			print "Creating link $link_filename -> $link_target\n" if $verbose;

			system_exec("cd $tmpDir ; ln -s $link_target $link_filename","Creating link $link_filename -> $link_target failed.");
	}

}

sub createDevicesInStaging($$) {
	my ($p_h_package, $build_dir) = @_;
	print "Creating devices\n"  if($verbose);

	foreach my $p_h_file (@{$p_h_package->{'contents'}->{'file'}}) {

			my $filename = $p_h_file->{'filename'};

			next unless exists($p_h_file->{'type'}->{'DEVICE'});

			my $devType = lc($p_h_file->{'devtype'});
			my $devMinor = '';
			my $devMajor = '';

			$devMinor = $p_h_file->{'minor'} if exists($p_h_file->{'minor'});	
			$devMajor = $p_h_file->{'major'} if exists($p_h_file->{'major'});

			my $devFilename = File::Spec->catfile($tmpDir,$filename);
			my ($volume1,$targetPath) = File::Spec->splitpath($devFilename);

			# create the target directory, if it doesn't exist
			createDirUnlessItExists($targetPath,$p_h_package);

			if (	$devType ne 'b' && 
					$devType ne 'c' && 
					$devType ne 'u' && 
					$devType ne 'p') {
				die "$devType is not a supported device type (should be b,c,u, or p" ;
			}
			
			print "Creating device $devFilename: type $devType, major=$devMajor, minor=$devMinor\n" if $verbose;

			system_exec("mknod $devFilename $devType $devMajor $devMinor","Creating device $devFilename failed.");
	}

}


# prototype - needed because of the recursion
sub generateFileList($$);
sub generateFileList($$) {
	my ($current_dir, $p_h_package_contents) = @_;;
	print "Generating list of files in lrp\n"  	if ($verbose && $current_dir eq '.');

	# after generateFileList completes, the $p_h_packageContents hashref contains
	# the file-names in the package
	# the hash-key is the filename, the value either DIR or FILE
	# directories are _NOT_ added to the ".list" file automatically
	# so, if the package should "own" a directory, it _must_ be
	# specified in the config as a "LIST" file


	# Get the contents.
	my $dirFH = Symbol::gensym();

	if (! opendir($dirFH, File::Spec->catdir($tmpDir, $current_dir))) {
		cleanTempDir();
		confess("Can't opendir (" . File::Spec->catdir($tmpDir, $current_dir) . "). $!");
	}
	my @files = readdir($dirFH);
	closedir($dirFH);

	foreach my $file (@files) {
		next if $file eq '.' || $file eq '..';
		my $filename = File::Spec->catdir($current_dir, $file);

		# recursively descend through the directories - but don't follow symlinks
		# to avoid loops and duplicate files
		if (-d File::Spec->catdir($tmpDir,$current_dir, $file)
			&& ! -l File::Spec->catdir($tmpDir,$current_dir, $file)
		) {
			#should not be included in the .list file
			# (unless they're specified in the config)
			# but we need them later on for the ownerships/permissions
			$p_h_package_contents->{$filename} = 'DIR';
			generateFileList(
						$filename,
						$p_h_package_contents
					);
		} else {
			$p_h_package_contents->{$filename} = 'FILE';
		}

	}


}

sub writeToFile($$) {
	my ($file_name, $file_contents) = @_;

	my $fh = Symbol::gensym();
	if (! open($fh, ">$file_name")) {
		cleanTempDir();
		confess("Can't open file ($file_name). $!");
	}
	print $fh $file_contents;
	close($fh);

}

sub generateLrpkgFiles($$$) {
	my ($p_h_package, $p_h_package_contents, $p_h_options) = @_;;
	print "Generating lrpkg files\n"  if $verbose;

	my $destDir = File::Spec->catdir($tmpDir, 'var','lib','lrpkg');
	my $str;

	# create the target directory, if it doesn't exist
	createDirUnlessItExists($destDir,$p_h_package);

	my $p_h_packageConf = packageConf($p_h_package);
	foreach my $confFile (keys %{$p_h_packageConf}) {
		$str = join("\n", @{$p_h_packageConf->{$confFile}});
		
		if ($str ne '') {
			writeToFile(File::Spec->catfile($destDir, $confFile . ".conf"),
					$str . "\n"
				);

			# now inject this file into the list of files in the package
			# needed so the .list file will be generated properly
			$p_h_package_contents->{File::Spec->catfile('var','lib','lrpkg',$confFile . ".conf")} = 'FILE';
		}
	}
	
	$str = packageHelp($p_h_package); 
	writeToFile(File::Spec->catfile($destDir, $p_h_package->{'packagename'} . ".help"),
				$str . "\n"
		) unless $str eq '';

	$str = packageVersion($p_h_package);
	writeToFile(File::Spec->catfile($destDir, $p_h_package->{'packagename'} . ".version"),
				$str . "\n"
		) unless $str eq '';

	$str = packageModules($p_h_package); 
	writeToFile(File::Spec->catfile($destDir, $p_h_package->{'packagename'} . ".modules"),
				$str . "\n"
		) unless $str eq '';


#	$str = packageList($p_h_package, $p_h_package_contents,$p_h_package->{'packagename'});
#	writeToFile(File::Spec->catfile($destDir, $p_h_package->{'packagename'} . ".list"),
#				$str . "\n"
#		) unless $str eq '';

	
#	$str = packageExclude($p_h_package);
#	writeToFile(File::Spec->catfile($destDir, $p_h_package->{'packagename'} . ".exclude.list"),
#				$str . "\n"
#		) unless $str eq '';

	$str = packageLocal($p_h_package);

	print ".local: $str\n" if $verbose;
	writeToFile(File::Spec->catfile($destDir, $p_h_package->{'packagename'} . ".local"),
				$str . "\n"
		) unless $str eq '';

	$str = packageLicense($p_h_package);
	system_exec("cd $destDir ; ln -s licenses/$str $p_h_package->{'packagename'}.license"
		) unless $str eq '';

}

sub applyOwnershipsAndPermissions($$;$) {
	my ($p_h_package, $p_h_package_contents, $firstrun) = @_;;
	print "Setting file ownerships and permissions\n"  if $verbose;


	foreach my $file (keys %{$p_h_package_contents}) {
		my $permission=0;
		my $ownership=0;

		my $defaultPermission;
		my $defaultOwnership;

	
		# setup defaults
		if ($p_h_package_contents->{$file} eq 'FILE') {
			$defaultPermission = $p_h_package->{'permissions'}->{'files'} ;
			$defaultOwnership = $p_h_package->{'owner'}->{'files'};
		} else {
			$defaultPermission = $p_h_package->{'permissions'}->{'directories'} ;
			$defaultOwnership = $p_h_package->{'owner'}->{'directories'};
		}


		if (!File::Spec->file_name_is_absolute($file)) {
			$file =File::Spec->catfile($tmpDir,$file  )
		}

		# check if there's a permission/owner specified
		foreach my $p_h_file (@{$p_h_package->{'contents'}->{'file'}}) {
			my $filename = $p_h_file->{'filename'};

			if (!File::Spec->file_name_is_absolute($filename)) {
				$filename =File::Spec->catfile($tmpDir,$filename )
			}
			
			my $wildcardMatch = 0;
			
			# find out if the source contained a wildcard
			# at this point, only wildcards in the filename, 
			# but not in the path are supported
			if (defined($p_h_file->{'source'})) {
				my ($sourceVolume,$sourcePath,$sourceFile) = File::Spec->splitpath( $p_h_file->{'source'} );
				
				$sourceFile =~ s/\./\\\./ig;
				$sourceFile =~ s/\*/\.\*/ig;
				# make sure a "+" in the filename doesn't screw up our regex
				$sourceFile =~ s/\+/\\\+/ig;


				my $regexFilename = $filename;
				$regexFilename =~ s/\./\\\./ig;
				$regexFilename =~ s/\*/\.\*/ig;
				# make sure a "+" in the filename doesn't screw up our regex
				$regexFilename =~ s/\+/\\\+/ig;
			
				# We must assume that $filename is a directory, if
				# source contained wildcards
				$sourceFile =File::Spec->catfile($regexFilename,$sourceFile );

				$wildcardMatch = 1 if $file =~ /^$sourceFile$/g;
			}
			
			# tricky - problematic when a file entry as well as a wildcard matches
			# if that happens, the file entry overrides the wildcard match
			if ($file eq $filename && (!defined($p_h_file->{'source'}) || $p_h_file->{'source'} !~ /\*/g)) {
				$permission = $p_h_file->{'permissions'} if exists($p_h_file->{'permissions'} );
				$ownership = $p_h_file->{'owner'} if exists($p_h_file->{'owner'});
				last;
			}
			
			if ($wildcardMatch && !$ownership) {
				$permission = $p_h_file->{'permissions'} if exists($p_h_file->{'permissions'} );
				$ownership = $p_h_file->{'owner'} if exists($p_h_file->{'owner'});			
			}

		}
		
		$permission = $defaultPermission unless $permission;
		$ownership = $defaultOwnership unless $ownership;

		# fetch the numeric uid/gid is user- and group-names were specified
		my ($uid, $gid) = split(/\:/,$ownership);

		if (!isNumeric($uid)) {
			 $uid   = getpwnam($uid);
			 confess "$uid not in passwd file" unless defined($uid);
		}

		if (!isNumeric($gid)) {
			 $gid   = getgrnam($gid);
			 confess "$gid not in passwd file" unless defined($gid);
		}

		#chown($uid, $gid, $file) or die "chown failed on $file";
		# --- don't use perl's chown, since it doesn't work on
		# symlinks (at least on V5.6.1
		system_exec("chown -h $uid:$gid $file","chown failed on $file");

		print "chown $uid:$gid $file\n"  if $verbose;
				
		# don't change permissions of links
		if (! -l $file) {
			# make sure this looks like an octal to perl
			$permission = '0' . $permission   unless $permission =~ /^0/;
			chmod(oct($permission),$file) or die "chmod $permission failed on $file";

			print "chmod $permission $file\n"  if $verbose;
		}

	}
}

sub copyExistingLrpToPackageStaging($) {
	my ($lrp_file) = @_;

	print "Extracting lrp\n"  if $verbose;
	system_exec("cd $tmpDir ; $genlrp_unp -c -d $lrp_file | tar -xvf - 2>&1 > /dev/null","Extracting lrp-file failed.");
}

sub createRegularLRP($$$$) {
	my ($p_h_package, $package_dir,$p_h_options, $gzip_options) = @_;
	print "Creating lrp\n"  if $verbose;	
	my $package_filename = $p_h_package->{'packagefilename'};
	my $cmd ="cd $tmpDir ; tar cvf - * 2>/dev/null | $genlrp_pkr $gzip_options > $package_dir/$package_filename.lrp ";
	system_exec($cmd,"Creating lrp package failed.");
#sign
	if ($sign) {
	my $signcmd ="cd $tmpDir ; gpg --local-user $localuser --quiet --passphrase $passphrase --yes --output $package_dir/$package_filename.gpg --detach-sign --armor $package_dir/$package_filename.lrp";
	system_exec($signcmd,"Signing package failed!");
	}
	system_exec("chown -h $lrp_owner:$lrp_group $package_dir/$package_filename.lrp","chown failed on $package_dir/$package_filename.lrp ");
}

sub createInitrd($$$$) {
	my ($p_h_package, $package_dir,$p_h_options, $gzip_options) = @_;

	my $package_filename = $p_h_package->{'packagefilename'};
	$initrdImage = "$package_dir/$package_filename";
	my $mountpoint = $tmpDir;	
	my $cmd ="cd $tmpDir ; ls; find . -print | cpio -o -H newc | gzip -9 -c - > $package_dir/$package_filename.lrp ";

	system_exec($cmd,"Creating lrp package failed.");

#sign
	if ($sign) {
	my $signcmd ="cd $tmpDir ; gpg --local-user $localuser --quiet --passphrase $passphrase --yes --output $package_dir/$package_filename.gpg --detach-sign --armor $package_dir/$package_filename.lrp";
	system_exec($signcmd,"Signing package failed!");
	}

#	system_exec("sync;sync;sync");
#	system_exec("umount $mountpoint","failed to unmount $mountpoint/");
#	system_exec("$initrd_pkr -9 $initrdImage","failed to $initrd_pkr -9 $initrdImage");
#	system_exec("mv $initrdImage.$initrd_ext $initrdImage.lrp","failed to mv $initrdImage.$initrd_ext $initrdImage.lrp");
	system_exec("chown -h $lrp_owner:$lrp_group $initrdImage.lrp","chown failed on $initrdImage.lrp ");
	$initrdImage = 0;
}

sub createLrpPacket($$$$) {
	my ($p_h_package, $package_dir,$p_h_options, $gzip_options) = @_;
		
	if ($buildInitrd) {
		createInitrd($p_h_package, $package_dir,$p_h_options, $gzip_options);	
	} else {
		createRegularLRP($p_h_package, $package_dir,$p_h_options, $gzip_options);
	}
}
sub readFile($) ;
sub readFile($) {
	my ($filename) = @_;
	my $lines = [];
	my $line ;

	# find the file to read
	# Get the contents.
	my $dirFH = Symbol::gensym();

	my $hInputFile     = Symbol::gensym();
	open($hInputFile,$filename) or die "Could not open file $filename\n";
	my ($volume,$destination_path,$file) = File::Spec->splitpath( $filename );	

	$line = '';
	while($line = <$hInputFile>){
	
		# Replace #include <filename> with the contents of "filename"
		if ($line=~ /#\s*include\s*\<([^\>]*)\>/ig) {
			# avoid endless loops 
			if ($filename ne $1) {
				my $includedFile = readFile(File::Spec->catfile($destination_path,$1));
				$line =~ s/#\s*include\s*\<[^\>]*\>/$includedFile/igs;
			}
		}

	
		push(@{$lines},$line);
	}
	close($hInputFile);

	return join('', @$lines,"\n");
}

sub readConfig($) {
	my ($filename) = @_;
	
	my $config = readFile($filename);
	my $p_h_pkgcfg = new Config::General(
			"-String" => $config,
			"-LowerCaseNames" => 1,
			"-ExtendedAccess"=> 1
		);

	
}
# MAIN

# only root (or fakeroot) may use this (we need to do chown...)
die "$0 can only be run as root" unless $>==0;

Getopt::Long::GetOptions($options,
					'package=s',
					'target=s',
					'lrp=s',
					'packager=s',
					'verbose',
					'sign',
					'toolchain=s',
					'all')	or die $Usage;

die $Usage unless exists($options->{'package'});

if (!exists($options->{'target'})) {
	$options->{'target'} = $options->{'package'} unless exists($options->{'target'});
	$options->{'all'} = 1;
}

$verbose = exists($options->{'verbose'}) ? 1 : 0;

$sign = exists($options->{'sign'}) ? 1 : 0;

my $baseDir	= File::Spec->rel2abs(File::Basename::dirname($0));



#fetch the buildtool config
my $btConfig= new Config::General(
			"-ConfigFile" => File::Spec->catfile(
							$baseDir,
							'conf',
							'buildtool.conf'),
			"-LowerCaseNames" => 1,
			"-ExtendedAccess"=> 1
		);


$lrp_owner = $btConfig->value('lrpowner') if $btConfig->exists('lrpowner');
$lrp_group = $btConfig->value('lrpgroup') if $btConfig->exists('lrpgroup');

$passphrase = $btConfig->value('passphrase') if $btConfig->exists('passphrase');
$localuser = $btConfig->value('packager') if $btConfig->exists('packager');

$options->{'mountpoint'} = "/mnt/loop";
$options->{'mountpoint'} = $btConfig->value('mountpoint') if $btConfig->exists('mountpoint');
$options->{'mkminixfs'} = "tools/busybox mkfs.minix";
$options->{'mkminixfs'} = $btConfig->value('mkminixfs') if $btConfig->exists('mkminixfs');
$mountcmd = "mount";
$mountcmd = $btConfig->value('mountcmd') if $btConfig->exists('mountcmd');
$umountcmd = "umount";
$umountcmd = $btConfig->value('umountcmd') if $btConfig->exists('umountcmd');

if (exists($options->{'toolchain'})) {
	$toolchain = $options->{'toolchain'};
} else {
	if (defined($btConfig->value('toolchain'))) {
		$toolchain = $btConfig->value('toolchain');
	} else {
		$toolchain = "undefined";
	}
}
print "Using toolchain $toolchain\n"  if $verbose;

$sourceDir	= File::Spec->canonpath(
					File::Spec->catdir(
						$baseDir,
						$btConfig->value('source_dir'),
						$options->{'package'})
			);

$stagingDir	= File::Spec->canonpath(
					File::Spec->catdir(
						$baseDir,
						'staging',
						$toolchain)
			);

$packageDir	= File::Spec->canonpath(
					File::Spec->catdir(
						$baseDir,
						'package',
						$toolchain)
			);

my $installedFile = File::Spec->canonpath(
					File::Spec->catfile(
						$baseDir,
						$btConfig->value('installedfile'))
				);


if (exists($options->{'packager'})) {
	$packager =  $options->{'packager'};
} else {
	# get the packager from the config (if available)
	if (defined($btConfig->value('packager'))) {
		$packager =  $btConfig->value('packager');
	} else {
		$packager =  "anonymous";
	}
}


# see if the package has been built at all
my $installed = new Config::General(
		"-ConfigFile" => $installedFile,
		"-LowerCaseNames" => 1,
		"-ExtendedAccess"=> 1
	);

my $foundBuiltPackage=0;
foreach my $packageName (@{$installed->value('build')}) {
	if (uc($packageName) eq uc($options->{'package'})) {
		$foundBuiltPackage = 1;
		last;
	}
}

if (!$foundBuiltPackage) {
	die "Package " . $options->{'package'} . " has not been built yet!\n";
}


$gzipOptions = $btConfig->value('gzip_options');
$gzipOptions = '-9' unless defined($gzipOptions) && $gzipOptions;


# fetch the global config
my $globalConfig= new Config::General(
			"-ConfigFile" => File::Spec->catfile(
						$baseDir,
						$btConfig->value('globalconffile')),
			"-LowerCaseNames" => 1,
			"-ExtendedAccess"=> 1
		);

# fetch the package specific config

my $packageConfig= readConfig(File::Spec->catfile(
						$sourceDir,
						$btConfig->value('buildtool_config')));

my $p_l_targets = [];

if (exists($options->{'all'})) {
	# fetch all possible targets for this package
	foreach my $target (keys(%{$packageConfig->value('package')})) {
		push(@$p_l_targets, $target);
	}
} else {
	push(@$p_l_targets, $options->{'target'});
}



foreach my $target (@$p_l_targets) {
	
	print "Generating package $target\n";
	my $p_h_package = $packageConfig->value('package')->{$target};
	
	die "Could not read package config for package " . $target
		unless defined($p_h_package);
	
	my $packageType = exists($p_h_package->{'packagetype'}) ? lc($p_h_package->{'packagetype'}) : 'lrp';
	
	if (uc($packageType) eq uc('lrp')) {
		$buildInitrd = 0;
	} else {
		if  (uc($packageType) eq uc('initrd')){
			$buildInitrd = 1;
		} else {
			die "unknown package type $packageType";
		}
	}

	
#	if ($buildInitrd) {
#		$foundBuiltPackage=0;
#		foreach my $pkgName (@{$installed->value('build')}) {
#			if (uc($pkgName) eq uc('busybox')) {
#				$foundBuiltPackage = 1;
#				last;
#			}
#		}
#		die "busybox source must be built before you can create a package of type initrd" unless $foundBuiltPackage;
#	}
	
	# get the filename to generate
	if (!exists($p_h_package->{'packagename'})) {
		$p_h_package->{'packagename'} = $target;
	}

	$p_h_package->{'packagefilename'} = $target;



	# turn the list if $p_h_package->{'contents'}->{'file'}->{'type'} into a hash

	# only one file in this package
	if (ref($p_h_package->{'contents'}->{'file'}) ne 'ARRAY') {
		my $p_h_file = $p_h_package->{'contents'}->{'file'};
		$p_h_package->{'contents'}->{'file'} = [];
		push(@{$p_h_package->{'contents'}->{'file'}}, $p_h_file);
	}

	foreach my $p_h_file (@{$p_h_package->{'contents'}->{'file'}}) {

		my $p_l_list;

		if (ref($p_h_file->{'type'}) eq 'ARRAY') {
			$p_l_list = $p_h_file->{'type'};

		} else {
			$p_l_list = [$p_h_file->{'type'}];
		}



		$p_h_file->{'type'} = {};
		foreach my $type (@{$p_l_list}) {
			$p_h_file->{'type'}->{uc($type)} = 1;
		}

	#use Data::Dumper;
	#my $dumper = Data::Dumper->new([$p_h_file]);
	#$dumper->Indent(1);
	#print STDERR  $dumper->Dumpxs(), "\n";

	}


	# find the skelFile
	$skelFile  = $p_h_package->{'skeleton'};

	# ok, finally...

	# create a temporary directory
	$tmpDir = prepareTempDir($p_h_package, $packageDir, $options);

	# extract the skel file to the tempdir (if we have a skel file)
	copySkelFileToPackageStaging($skelFile, $sourceDir) if (defined($skelFile));

	# (optional) copy existing lrp
	if (exists($options->{'lrp'})) {
		my $lrpFile = File::Spec->catfile(
							$baseDir,
							$options->{'lrp'}
						);

		print "Importing lrp: $lrpFile\n" if $verbose;
		copyExistingLrpToPackageStaging($lrpFile) ;
	}

	# create empty directories, if needed
	createDirectories($p_h_package, $stagingDir);

	# copy binaries
	copyBinariesToPackageStaging($p_h_package, $stagingDir);
	
	# create devices
	createDevicesInStaging($p_h_package, $stagingDir);
	
	# create links
	createLinksInStaging($p_h_package, $stagingDir);

	# TODO
	# add hook for "interactive" mode

	# create list of files
	my $p_h_packageContents = {};
	generateFileList('.', $p_h_packageContents);

	# generate lrpkg files
	generateLrpkgFiles($p_h_package, $p_h_packageContents,$options);

	# set up permissions
	applyOwnershipsAndPermissions($p_h_package, $p_h_packageContents);

	# create new lrp file in $packageDir
	createLrpPacket($p_h_package, $packageDir, $options, $gzipOptions);

	#clean up tmpDir
	cleanTempDir();
}

exit;

__END__

=pod

=head1 NAME

buildpackage - create an lrp-package from the files created with buildtool

=head1 SYNOPSIS

B<buildpackage> --package=packagename --packager=name_of_packager [--target=packagefile] [-lrp=existing.lrp] [--verbose]

=head1 DESCRIPTION

B<buildpackage> Creates a new lrp-file, using the files created with buildtool
Lists the contents of LEAF packages. The packages to be

=head1 SEE ALSO

http://leaf.sourceforge.net/doc/guide/bucd-buildpacket.html

=cut


