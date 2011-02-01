#! /usr/bin/perl

# this script analysis a given lrp/leaf file and makes a file list
# out of it, and make a script that builds the proper owner/permission
# settings

#$Id: analyse-lrp-package.pl,v 1.1.1.1 2010/04/26 09:03:16 nitr0man Exp $

require POSIX;
require File::MMagic;
require Config::General;


my @filelist;
my @binfiles;

my %config = ( Default => { Permissions => { Files => 644,
					     Directories => 0755 },
			    

my $MM = new File::MMagic();
if ($ENV{EDITOR} eq "") {
  $EDITOR = "/usr/bin/joe";
} else {
  $EDITOR = $ENV{EDITOR};
} 

sub usage () {
  print "$0 usage: <archivename>\n\n";
  print "This Program analyses a leaf package,\n";
  print "two files will be created, <archivename>.skel.tar.gz\n";
  print "and <archivename>.chperms.sh, which is a shell script\n";
  print "you can use to change permissions to the state they were\n";
  print "(if you are making the binaries new)";
  exit;
}

if ($#ARGV != 0) {
 usage();
}

sub makePermFileLine() {
  my $line = shift;
  my $permline = "";
  my $permline1 = "";
  my ($perms, $owner, $size, $date, $time, $name) = split(' ',$line, 6);
  # delete dir stuff:
  $type = substr($perms, 0 , 1);
    chop($name);
  if ($type ne 'l') { 
    $perms = substr($perms, 1,);
    $permstring = &makePerms($perms);
    $permline .= "chown " . &makeOwner($owner) . " \${PREFIX}\/". $name . "\n";
    $permline1 = "chmod ". $permstring . " \${PREFIX}\/". $name . "\n";
  } else {
    # is link
    $name =~ s/^(.+) -> .*$/$1/;
    $permline .= "chown " . &makeOwner($owner) . " \${PREFIX}\/". $name . "\n";
  }
  return   "\n# file: $name\n" . $permline . $permline1;
}

sub makePerms () {
  my $perms = shift;
  my $retval = "";
  if (length($perms) != 9) {
    die "string is buggy";
  }
  $retval .= &makePerm('u', substr($perms, 0, 3));
  $retval .= &makePerm('g', substr($perms, 3, 3));
  $retval .= &makePerm('o', substr($perms, 6, 3));
  # remove last ,
  chop ($retval);
  return $retval;
}

sub makeOwner () {
  my $owner = shift;
  $owner =~ s/\//\./;
  return $owner;
}

sub makePermFileHead () {
  my $name = shift || "noname";
  $head = "#! /bin/sh\n\n";
  $head .= "## file to correct chown/chmod for package " . $name . "\n";
  $head .= "# generated ". POSIX::strftime("%d.%m.%Y %H:%M", gmtime(time())) . "\n";
  $head .= "\n# set PREFIX here\n";
  $head .= "PREFIX=\"\"\n\n";
  $head .= "# use commandline to overwrite prefix\n";
  $head .= "\n if  [ \"x\$1\" != \"x\" ] ; then \n";
  $head .= "PREFIX=\$1\nfi\n";
  $head .= "\n\n# just to be sure \nif [ \"x\$PREFIX\" = \"x\" ] ; then\n";
  $head .= "echo no prexix set, this is DANGEROUS, exiting\n exit 1";
  $head .= "\nfi\n\n";
  return $head;
}

sub makePerm () {
  my $prefix = shift;
  my $perms = shift;
  my $retval = "";

#  print "perms2:$perms\n";
  foreach $perm (split('', $perms,)) { 
    if ($perm =~ /^-$/) {
      # continue
    } else {
      # else
      $retval .= $perm;
    }
  }
  if (length($retval) > 0) {
    $retval = $prefix . "=".$retval . ",";
  }
  return $retval;

}

sub unpackTar () {
  my $file = shift;
  my $tempdir = shift || "/tmp";
  # create tempdir
  system('mkdirhier', $tempdir);
  # unpack everything
  system('tar', '-C', $tempdir, '-xzf', $file);
}

sub makeBinaryFileList () {
  # makes a list of all binary files found in directory
  my $startdir = shift || die "startdir not set";
  my $tempdir = shift || $startdir;
  my @list = ();
  opendir(STARTDIR, $startdir) or die "cannot open dir $startdir";
  my @alledateien = grep !/^\.\.?$/, readdir STARTDIR;

  foreach my $datei (@alledateien) {
    my $fpdatei = $startdir . "/" . $datei;
#    print "-->$fpdatei\n";

    push(@filelist, $fpdatei);
    if (-d $fpdatei) {
      # recurse!
#      print "recurse!";
      &makeBinaryFileList($fpdatei, $tempdir);
    } elsif (! -l ) {
      # file, not link!
      # remove starting dir
      # print filetype
      # check if file is binary
      if (&fileIsBinary($fpdatei)) {
	my $rpdatei = $fpdatei;
	$rpdatei =~ s/^$tempdir\/// ;
	push(@binfiles, $rpdatei);
      }
    }
  }
  closedir(STARTDIR);

}

sub makeSkelTar () {
  my $tarfile = shift || die "no tar filename given";
  my $list = shift  || return;

  my @BINLIST = @{$list};
  my $packagename = $tarfile;
  $packagename =~ s/(.*)\.[a-zA-Z]+/$1/ ;

  my $skelname = $packagename . ".skel.tgz";
  # first copy
  if (system ('cp', '-f', $tarfile, $skelname) != 0) {
    die "copying failed";
  }
  # gunzip
  if (system ('gunzip' , '-f', $skelname) != 0) {
    die "gunzip failed";
  }
  # now remove the files (binfiles) from archive
  $skelname =~ s/(.*)\.tgz$/$1\.tar/;
#  print "skelname:$skelname";

  # make a chmod to be sure:
  if (system ('chmod u+w '. $skelname) != 0 ) { 
    die "chmod failed"; 
 } 

  foreach $name (@BINLIST) {
    print "deleting file entry:$name\n";
  }
  #
  if (system('tar', '--delete', '-vf', "./". $skelname, @BINLIST) != 0) {
    die "tar --delete failed";
  }

  if (system ('gzip' , '-f', $skelname) != 0) {
    die "gzip failed";
  }


}

sub fileIsBinary ()  {
  my $fullpath = shift || return 0;
  $type = $MM->checktype_filename($fullpath);
  if ($type =~ /^application/) {
#    print $fullpath . ":" . $type . "\n";
    return 1;
  } else {
    return 0;
  }
}


########################################################################
# test if we can open the file:
# now set archive name:

print "Analysing package, please wait\n";

$packagename = $ARGV[0];
$packagename =~ s/(.*)\.[a-zA-Z]+/$1/ ;

#print "name : $packagename\n";

open (TEST, $ARGV[0]) or die "cannot open file " . $ARGV[0];
close (TEST);
open(TAR, "tar -tvzf $ARGV[0] 2>/dev/null |") or die "open tar failed";

$chmodfile = "./" . $packagename . ".chperms.sh";
open (CHMODFILE, ">$chmodfile");


print CHMODFILE &makePermFileHead($ARGV[0]);
while ($line = <TAR>) {
#  print "$line";
  print CHMODFILE &makePermFileLine($line) ;
}
close(TAR);
close(CHMODFILE);

if (system("chmod", "755", $chmodfile) != 0) {
  die "chmod failed";
}

my $UNPACK_DIR = "/tmp/unpack";

system('rm', '-rf', $UNPACK_DIR);
&unpackTar($ARGV[0], $UNPACK_DIR);
&makeBinaryFileList($UNPACK_DIR);

$filelistfile = "./" . $packagename . ".bin-list";
open(FILELIST , ">$filelistfile");
#print "einträge: " . scalar(@filelist) . "\n";

print FILELIST "# The following file seem to be binary executable/libs and are\n# to be removed for the skel.tgz:\n# please edit this list, after saving the files in here will be removed\n# from the skel.tar!\n# Please do not change this lines!\n";

foreach $name (@binfiles) {
print FILELIST "$name\n";
}
close(FILELIST);

system($EDITOR, "$filelistfile");

open (BINLISTFILE, $filelistfile);

while (my $line = <BINLISTFILE>) {
  if ($line =~ /^\#/) {
    # oh yes it is a comment!
  } else {
    # normal line
    chop($line);
#    print "--" . $line . "--\n";
    push (@BINLIST, $line);
  }
}
&makeSkelTar($ARGV[0], \@BINLIST);
