#! /bin/sh
#
# Copyleft 2008 Erich Titl (erich.titl@think.ch)
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See <http://www.fsf.org/copyleft/gpl.txt>.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# $Id: passcheck.sh,v 1.1 2008/11/28 13:42:19 etitl Exp $

HTPASSWD=/var/webconf/www/.htpasswd
HTPASS_FLAG=/var/webconf/www/.htpasswd.flag

# this is to avoid endless loops
[ -f $HTPASS_FLAG ] && rm $HTPASS_FLAG && exit

if [ ! -s $HTPASSWD ]; then  
	touch $HTPASS_FLAG 
else
	passwd=`cat $HTPASSWD | cut -f2 -d:`
	[ "$passwd" == "" ] && touch $HTPASS_FLAG 
fi

[ -f $HTPASS_FLAG ] && echo '<META http-equiv="refresh" content="0;URL=/wc-passwd.cgi">'

