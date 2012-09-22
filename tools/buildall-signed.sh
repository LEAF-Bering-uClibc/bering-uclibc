#! /bin/bash
#set -x
# call this from the 
#
# (c) 2005 Arne Bernin
# distributed under GPL 



############# change this if needed #####################
#EXPORTDIR=/home/arne/leaf/buildall
EXPORTDIR=/tmp

#########################################################
BTROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null)
DATE=$(date "+%Y-%m-%dT%H:%M")
STARTDATE=$(date)
MYDIR=$EXPORTDIR/$DATE
HTMLFILE=$MYDIR/build.html
BTBIN=$BTROOTDIR/buildtool.pl
BPBIN=$BTROOTDIR/buildpacket.pl

################## set environment ######################
tmpfile=$(mktemp)
$BTBIN dumpenv > $tmpfile || exit 1
source $tmpfile || exit 1
rm -f $tmpfile
TOOLCHAIN=$GNU_TARGET_NAME
EXITVALUE=0


print_usage() {
cat <<EOF 

This script builds all packages/sources defined in conf/source.cfg 
in the correct order of dependencies. You may adjust the ouput base
dir in the script (EXPORTDIR) at the beginning as you need it.
$0 generates a html report with links to the logfiles of the build
in an subdirectory of EXPORTDIR, it contains links to the logfiles
from the build.

EOF
}

call_buildtool() {
	$BTBIN $1 $2 1>&2
	ret=$?
	if [ $ret -eq 0 ] ; then
		echo -n "<font color=green>OK</font>"
	else
		echo -n "<font color=red><b>FAILED</b></font>"
		EXITVALUE=1
	fi		
}

call_buildpacket() {
	echo "-------------------------" >> $MYDIR/$name.build.txt 2>&1
	# check if it has a package definition in it:
	grep -qEi '<Package.*>' $BT_SOURCE_DIR/$1/buildtool.cfg 2>/dev/null
	if [ $? -eq 0 ] ; then
		echo "creating lrp packet(s) for '$name'..." >&2
		echo "calling buildpacket for $1 " >> $BT_LOG_FILE 2>&1

		fakeroot $BPBIN --package=$1 --all --sign >> $BT_LOG_FILE 2>&1
		ret=$?
		if [ $ret -eq 0 ] ; then
			echo -n "<font color=green>OK</font>"
		else
			echo -n "<font color=red><b>FAILED<b></font>"
			EXITVALUE=1
		fi		
	else
		echo -n "<font color=blue>No Package</font>"
	fi
}

#
if [ "$1" = "-h" -o "$1" = "--help" ] ; then
	print_usage
	exit 0
fi

############################# start ##############################
# create our working dir
mkdir -p $MYDIR


PKGLIST=$($BTBIN pkglist | tr ',' ' ');
PKGSIZE=$(echo $PKGLIST | tr ' ' '\n' | wc -l)

# wipe the buildtool logfile
> $BT_LOG_FILE

echo "report (build.html) will be generated in $MYDIR"

# open our html report
cat <<EOF >$HTMLFILE
<HTML>
<HEAD>
<TITLE>build report for $DATE</TITLE>
</HEAD>
<BODY>
<H3>Number of total packages:$PKGSIZE</H3>
<H3>Building using toolchain: $TOOLCHAIN</H3>
<p>
<TABLE cellpadding=10 border=1>
<tr>
<th>Package/Source</th><th>logfile</th><th>result<br>source</th><th>result<br>build</th><th>result<br>package</th>
</tr>
EOF


# main loop
for name in $PKGLIST; do
	echo "building $name"
	# clear logfile
	> $BT_LOG_FILE
	echo -n "<tr><td>$name</td><td><a href=$name.build.txt>$name.build.txt</a></td><td>" >> $HTMLFILE
	OLDEXITVALUE=$EXITVALUE
	EXITVALUE=0
	call_buildtool source $name >> $HTMLFILE
	echo  "</td><td>" >> $HTMLFILE

	if [ $EXITVALUE -eq 0 ] ; then
		call_buildtool build $name >> $HTMLFILE
		echo -n "</td><td>" >> $HTMLFILE
		
		if [ $EXITVALUE -eq 0 ] ; then	
			call_buildpacket $name >> $HTMLFILE		
			EXITVALUE=$OLDEXITVALUE	
		else
			echo -n "<font color=red><b>FAILED</b></font>" >> $HTMLFILE
			EXITVALUE=1
		fi
	else
		echo -n "<font color=red><b>FAILED</b></font>" >> $HTMLFILE
		echo -n "</td><td>" >> $HTMLFILE
		echo -n "<font color=red><b>FAILED</b></font>" >> $HTMLFILE
		EXITVALUE=1
	fi
	echo "</td></tr>" >> $HTMLFILE		
	# copy logfile
	cp $BT_LOG_FILE $MYDIR/$name.build.txt
	echo
done

echo "</TABLE>" >> $HTMLFILE
echo "<H3>build started: $STARTDATE<p>build ended: $(date)</H3>" >>$HTMLFILE
echo "</BODY>" >>$HTMLFILE
echo "</HTML>" >>$HTMLFILE

# did anything fail ?
exit $EXITVALUE
