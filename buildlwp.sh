#!/bin/bash
# This script will build the webconf standard .lwp files from buildtool dir source/lwp
#
# If necessary it adds the files with owner and permissions to a tarfile and then gzip's the tarfile

set -u

#########################################################
BTROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null || echo '.')
BTBIN=$BTROOTDIR/buildtool.pl

################## set environment ######################
tmpfile=$(mktemp)
$BTBIN dumpenv > $tmpfile || exit 1
source $tmpfile || exit 1
rm -f $tmpfile

lwpSrcDir=$BT_SOURCE_DIR/lwp

#
# webconf.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -cf $BT_PACKAGE_DIR/webconf.lwp              \
    var/webconf/www/lrcfg.cgi var/webconf/www/leafcfg.cgi etc/webconf/webconf-expert.webconf

tar -C $lwpSrcDir --owner=1003 --group=65534 --mode=644 \
    -rf $BT_PACKAGE_DIR/webconf.lwp var/webconf/www/blurb.expert
gzip -9 $BT_PACKAGE_DIR/webconf.lwp
mv $BT_PACKAGE_DIR/webconf.lwp.gz $BT_PACKAGE_DIR/webconf.lwp
echo "webconf.lwp"

#
# keyboard.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -cf $BT_PACKAGE_DIR/keyboard.lwp var/webconf/www/keyboard.cgi
tar -C $lwpSrcDir --owner=0 --group=0 --mode=644 \
    -rf $BT_PACKAGE_DIR/keyboard.lwp etc/webconf/keyboard.webconf
gzip -9 $BT_PACKAGE_DIR/keyboard.lwp
mv $BT_PACKAGE_DIR/keyboard.lwp.gz $BT_PACKAGE_DIR/keyboard.lwp
echo "keyboard.lwp"

#
# dropbear.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -cf $BT_PACKAGE_DIR/dropbear.lwp var/webconf/www/dropbear.cgi
tar -C $lwpSrcDir --owner=0 --group=0 --mode=644 \
    -rf $BT_PACKAGE_DIR/dropbear.lwp etc/webconf/dropbear.webconf
gzip -9 $BT_PACKAGE_DIR/dropbear.lwp
mv $BT_PACKAGE_DIR/dropbear.lwp.gz $BT_PACKAGE_DIR/dropbear.lwp
echo "dropbear.lwp"

#
# config.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -zcf $BT_PACKAGE_DIR/config.lwp var/webconf/www/config.cgi etc/webconf/config.webconf
echo "config.lwp"

#
# dnsmasq.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -cf $BT_PACKAGE_DIR/dnsmasq.lwp var/webconf/www/dnsmasq.cgi
tar -C $lwpSrcDir --owner=0 --group=0 --mode=644 \
    -rf $BT_PACKAGE_DIR/dnsmasq.lwp etc/webconf/dnsmasq.webconf
gzip -9 $BT_PACKAGE_DIR/dnsmasq.lwp
mv $BT_PACKAGE_DIR/dnsmasq.lwp.gz $BT_PACKAGE_DIR/dnsmasq.lwp
echo "dnsmasq.lwp"

#
# pppoe.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -zcf $BT_PACKAGE_DIR/pppoe.lwp  var/webconf/www/pppoe.cgi etc/webconf/pppoe.webconf
echo "pppoe.lwp"


#
# webipv6.lwp
#
tar -C $lwpSrcDir --owner=0 --group=0 --mode=755 \
    -cf $BT_PACKAGE_DIR/webipv6.lwp var/webconf/www/webipv6.cgi
tar -C $lwpSrcDir --owner=0 --group=0 --mode=644 \
    -rf $BT_PACKAGE_DIR/webipv6.lwp etc/webconf/webipv6.webconf
gzip -9 $BT_PACKAGE_DIR/webipv6.lwp
mv $BT_PACKAGE_DIR/webipv6.lwp.gz $BT_PACKAGE_DIR/webipv6.lwp
echo "webipv6.lwp"
