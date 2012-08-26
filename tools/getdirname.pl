#!/usr/bin/perl

use strict;
use warnings;

use File::Spec::Functions qw(:ALL);

sub usage() {
	print STDERR<<EOF;
	usage: $0 tarfile
EOF
exit(1);
}

sub help() {
	print <<EOF;
	$0 returns the dir name of the first
	entry of the given .tgz  / .tar.gz / .tar.bz2 file
EOF

	exit(0);
}

if ($#ARGV != 0) {
	usage();
}

help() if ($ARGV[0] eq "--help" or $ARGV[0] eq "-h");

my $filename=$ARGV[0];

my $filetype=`file -L --brief $filename`;
#print STDERR "file command says file is: $filetype\n";

my $filter_option = "";
if ( $filetype =~ /^bzip2/i ) {
	$filter_option = "--bzip2";
} elsif ( $filetype =~ /^gzip/i ) {
	$filter_option = "--gzip";
} elsif ( $filetype =~ /^lzip/i ) {
	$filter_option = "--lzip";
} elsif ( $filetype =~ /^lzop/i ) {
	$filter_option = "--lzop";
} elsif ( $filetype =~ /^LZMA/i ) {
	$filter_option = "--lzma";
} elsif ( $filetype =~ /^XZ/i ) {
	$filter_option = "--xz";
} else {
	die ( "unsupported file type $filetype" );
}

#print STDERR "trying to open $filename\n";
open DIRNAME, "tar t $filter_option -f $filename | head -1 |" or die("unable to open tarfile $filename ");
	
my $line=<DIRNAME>;
	chop $line;

close DIRNAME;

# Split path
my ( undef, $path, $file ) = splitpath($line);

# Split directories
my @directories = splitdir($path);

# Remove . and .. directories
shift @directories while exists $directories[0] && $directories[0] =~ /^\.\.?/;

# Get the top level directory
my $top_level_dir = shift @directories;

# Check is defined and not empty
die "unable to read dirs!\n" if not defined $top_level_dir or $top_level_dir eq "";

print $top_level_dir . "\n";

exit(0);
