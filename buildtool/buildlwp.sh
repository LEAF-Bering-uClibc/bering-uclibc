#!/bin/sh
# This script will build the webconf standard .lwp files from buildtool dir source/lwp
#
# If necessary it adds the files with owner and permissions to a tarfile and then gzip's the tarfile


# change to lwp dir
cd source/lwp

#
# webconf.lwp
#
tar --owner=0 --group=0 --mode=755 -cf ../../package/webconf.lwp var/webconf/www/lrcfg.cgi \
	var/webconf/www/leafcfg.cgi \
	etc/webconf/webconf-expert.webconf 
tar --owner=1003 --group=65534 --mode=644 -rf ../../package/webconf.lwp var/webconf/www/blurb.expert
gzip -9 ../../package/webconf.lwp 
mv ../../package/webconf.lwp.gz ../../package/webconf.lwp 
echo "webconf.lwp"


#
# keyboard.lwp
#
tar --owner=0 --group=0 --mode=755 -cf ../../package/keyboard.lwp var/webconf/www/keyboard.cgi
tar --owner=0 --group=0 --mode=644 -rf ../../package/keyboard.lwp etc/webconf/keyboard.webconf
gzip -9 ../../package/keyboard.lwp 
mv ../../package/keyboard.lwp.gz ../../package/keyboard.lwp 
echo "keyboard.lwp"
	
#
# dropbear.lwp
#
tar --owner=0 --group=0 --mode=755 -cf ../../package/dropbear.lwp var/webconf/www/dropbear.cgi
tar --owner=0 --group=0 --mode=644 -rf ../../package/dropbear.lwp etc/webconf/dropbear.webconf
gzip -9 ../../package/dropbear.lwp 
mv ../../package/dropbear.lwp.gz ../../package/dropbear.lwp 
echo "dropbear.lwp"


#
# ifaces.lwp
#
tar --owner=0 --group=0 --mode=755 -cf ../../package/ifaces.lwp var/webconf/www/interfaces.cgi \
			  var/webconf/www/interfaces.js \
			  var/webconf/www/interfaces.blurb \
			  var/webconf/lib/networking.func \
			  etc/webconf/interfaces.webconf
tar --owner=0 --group=0 --mode=644 -rf ../../package/ifaces.lwp var/webconf/templates 
gzip -9 ../../package/ifaces.lwp 
mv ../../package/ifaces.lwp.gz ../../package/ifaces.lwp 
echo "ifaces.lwp"

#
# tools.lwp
#
tar --owner=0 --group=0 --mode=755 -zcf ../../package/tools.lwp var/webconf/www/ping.cgi \
			 etc/webconf/tools.webconf \
			 var/webconf/www/tracert.cgi 
echo "tools.lwp"


#
# config.lwp
#
tar --owner=0 --group=0 --mode=755 -zcf ../../package/config.lwp var/webconf/www/config.cgi \
				etc/webconf/config.webconf
echo "config.lwp"

#
# dnsmasq.lwp
#
tar --owner=0 --group=0 --mode=755 -cf ../../package/dnsmasq.lwp var/webconf/www/dnsmasq.cgi
tar --owner=0 --group=0 --mode=644 -rf ../../package/dnsmasq.lwp etc/webconf/dnsmasq.webconf
gzip -9 ../../package/dnsmasq.lwp 
mv ../../package/dnsmasq.lwp.gz ../../package/dnsmasq.lwp 
echo "dnsmasq.lwp"


#
# pppoe.lwp
#
tar --owner=0 --group=0 --mode=755 -zcf ../../package/pppoe.lwp	var/webconf/www/pppoe.cgi \
				etc/webconf/pppoe.webconf
echo "pppoe.lwp"


#
# webipv6.lwp
#
tar --owner=0 --group=0 --mode=755 -cf ../../package/webipv6.lwp var/webconf/www/webipv6.cgi
tar --owner=0 --group=0 --mode=644 -rf ../../package/webipv6.lwp etc/webconf/webipv6.webconf
gzip -9 ../../package/webipv6.lwp 
mv ../../package/webipv6.lwp.gz ../../package/webipv6.lwp 
echo "webipv6.lwp"

# go back
cd ../..