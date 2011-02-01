#
# checkroot.sh	Check to root file system.
#
RCDLINKS="S,S10"

. /etc/default/rcS
#
# Set SULOGIN to yes if you want a sulogin to be spawned from
# this script *before anything else* with a timeout, like on SCO.

[ "$SULOGIN" = yes ] && sulogin -t 30 $CONSOLE
