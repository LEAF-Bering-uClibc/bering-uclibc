#!/bin/sh

PKGLIST=`apkg -l|awk '{print $1 ";" $2 ":" $4}'`

PATH=/bin:/sbin:/usr/bin:/usr/sbin

. /etc/updater.conf

cd /tmp
wget $MIRROR/verinfo.cgi -O updatelist
UPDLIST=`cat updatelist`

for i in $UPDLIST; do
        PKG=`echo "${i//;/ }" | awk '{print $1}'`
	if [ -n "$(echo "$PKGLIST" | grep -e "^$PKG;")"  ]; then
            PVER=`echo "${i//;/ }" | awk '{print $2}'`
	    IVER=`echo "${PKGLIST//;/ }" | grep -e "^$PKG " | awk '{print $2}'`
    	    if [ "$PVER" != "$IVER" ] && [ -n "$IVER" ] ; then
        	PSCR=`echo "${i//;/ }" | awk '{print $3}'`
            	echo $PKG $PVER $IVER $PSCR
                wget $MIRROR/$PKG.lrp -O $PKG.lrp
		if [ "$1" = silent ]; then
		    apkg -f $PKG.lrp
		else
		    apkg -u $PKG.lrp
		fi
        	if [ "$PSCR" = "1" ]; then
            	    wget $MIRROR/pkgscripts/$PKG -O $PKG
    	        fi
    	        with_storage $MNT ipkg.move $PKG $PSCR
        	if [ -n "$LOGGING" ]; then
		    echo "`date`: $PKG $IVER -> $PVER" >>/var/log/updater.log
		fi
	    fi
        fi
done
rm -f updatelist
