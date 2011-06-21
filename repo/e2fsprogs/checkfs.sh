#
# checkfs.sh	Check all filesystems.
#
# Version:	@(#)checkfs  2.85-13  22-Mar-2004  miquels@cistron.nl
#
RCDLINKS="S,S30"

FSCKFIX=no
FSCKFORCE=no

#
# Check the file systems.
#
if [ "$FSCKFIX"  = yes ]
then
	fix="-y"
else
	fix="-a"
fi
if [ "$FSCKFORCE"  = yes ]
then
	force="-f"
else
	force=""
fi
spinner="-C"
case "$TERM" in
	dumb|network|unknown|"") spinner="" ;;
esac
echo "Checking all file systems..."
fsck $spinner -R -A $fix $force
if [ $? -gt 1 ]
then
	echo
	echo "fsck failed.  Please repair manually."
	echo
	echo "CONTROL-D will exit from this shell and continue system startup."
	echo
	# Start a single user shell on the console
	/sbin/sulogin $CONSOLE
fi

: exit 0