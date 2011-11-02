#!/bin/sh
# This script will build the webconf standard .lwp files from buildtool dir source/lwp
#
# If necessary it adds the files with owner and permissions to a tarfile and then gzip's the tarfile

ROOT=`pwd`
PKGDIR=package/i386

# change to lwp dir
cd source/lwp

#
# webconf.lwp
#
tar --owner=0 --group=0 --mode=755 -cf $ROOT/$PKGDIR/webconf.lwp var/webconf/www/lrcfg.cgi \
	var/webconf/www/leafcfg.cgi \
	etc/webconf/webconf-expert.webconf 
tar --owner=1003 --group=65534 --mode=644 -rf $ROOT/$PKGDIR/webconf.lwp var/webconf/www/blurb.expert
gzip -9 $ROOT/$PKGDIR/webconf.lwp 
mv $ROOT/$PKGDIR/webconf.lwp.gz $ROOT/$PKGDIR/webconf.lwp 
echo "webconf.lwp"


#
# keyboard.lwp
#
tar --owner=0 --group=0 --mode=755 -cf $ROOT/$PKGDIR/keyboard.lwp var/webconf/www/keyboard.cgi
tar --owner=0 --group=0 --mode=644 -rf $ROOT/$PKGDIR/keyboard.lwp etc/webconf/keyboard.webconf
gzip -9 $ROOT/$PKGDIR/keyboard.lwp 
mv $ROOT/$PKGDIR/keyboard.lwp.gz $ROOT/$PKGDIR/keyboard.lwp 
echo "keyboard.lwp"
	
#
# dropbear.lwp
#
tar --owner=0 --group=0 --mode=755 -cf $ROOT/$PKGDIR/dropbear.lwp var/webconf/www/dropbear.cgi
tar --owner=0 --group=0 --mode=644 -rf $ROOT/$PKGDIR/dropbear.lwp etc/webconf/dropbear.webconf
gzip -9 $ROOT/$PKGDIR/dropbear.lwp 
mv $ROOT/$PKGDIR/dropbear.lwp.gz $ROOT/$PKGDIR/dropbear.lwp 
echo "dropbear.lwp"

#
# config.lwp
#
tar --owner=0 --group=0 --mode=755 -zcf $ROOT/$PKGDIR/config.lwp var/webconf/www/config.cgi \
				etc/webconf/config.webconf
echo "config.lwp"

#
# dnsmasq.lwp
#
tar --owner=0 --group=0 --mode=755 -cf $ROOT/$PKGDIR/dnsmasq.lwp var/webconf/www/dnsmasq.cgi
tar --owner=0 --group=0 --mode=644 -rf $ROOT/$PKGDIR/dnsmasq.lwp etc/webconf/dnsmasq.webconf
gzip -9 $ROOT/$PKGDIR/dnsmasq.lwp 
mv $ROOT/$PKGDIR/dnsmasq.lwp.gz $ROOT/$PKGDIR/dnsmasq.lwp 
echo "dnsmasq.lwp"

#
# pppoe.lwp
#
tar --owner=0 --group=0 --mode=755 -zcf $ROOT/$PKGDIR/pppoe.lwp	var/webconf/www/pppoe.cgi \
				etc/webconf/pppoe.webconf
echo "pppoe.lwp"


#
# webipv6.lwp
#
tar --owner=0 --group=0 --mode=755 -cf $ROOT/$PKGDIR/webipv6.lwp var/webconf/www/webipv6.cgi
tar --owner=0 --group=0 --mode=644 -rf $ROOT/$PKGDIR/webipv6.lwp etc/webconf/webipv6.webconf
gzip -9 $ROOT/$PKGDIR/webipv6.lwp 
mv $ROOT/$PKGDIR/webipv6.lwp.gz $ROOT/$PKGDIR/webipv6.lwp 
echo "webipv6.lwp"

# go back
cd $ROOT