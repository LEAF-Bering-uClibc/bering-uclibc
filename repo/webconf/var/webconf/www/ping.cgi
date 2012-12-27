#!/usr/bin/haserl
#
# Copyleft 2012 Erich Titl (erich.titl@think.ch)
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See <http://www.fsf.org/copyleft/gpl.txt>
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
######################################################################
# $Id: ping.cgi,v 1.3 2012/05/03 08:59:23 etitl Exp $
######################################################################
<? # 

. /var/webconf/lib/validator.sh		# Sets colours CL0 to CL4
. /var/webconf/lib/networking.func	# make various functions for
					# networking available

TEMPLATE_DIR=/var/webconf/templates
FILTERDIR=/var/webconf/lib/filter

######################################################################
# this is for the calls to ifup/down and ip
######################################################################
PATH=$PATH:/sbin
export PATH
######################################################################

title="View/Configure network interfaces"  
/var/webconf/lib/preamble.sh 

######################################################################
# insert the javascript functions 
######################################################################
#cat <<-EOF
#<script src="interfaces.js" type="text/javascript"></script>
#EOF
######################################################################
######################################################################
# insert the interface css file
######################################################################
cat <<-EOF
        <link rel="stylesheet" type="text/css" href="/interfaces.css">
EOF
######################################################################

######################################################################
cat <<-EOF
<br><div id=info>
<p>
This page  allows you to run a ping command on your firewall 
</p>
</div>
EOF
######################################################################

TEMP=/tmp$SCRIPT_NAME$$

cat <<-EOF
	<form name=$SCRIPT_NAME_form action="$SCRIPT_NAME" method=post>
	<h1>Ping</h1>
EOF

  FORM_name="$( echo $FORM_name | to_html | sed "s-[^/a-zA-Z\.0-9\-_]--g" )"
  FORM_name_ok="$( ls -1 /var/log | grep "^$FORM_name\$" )"


cat <<-EOF
<div id="interfaces">
<table cellspacing=0 cellpadding=2>
<colgroup> <col width="250"><col width="120"><col width="40"><col width="40"><col width="40"></colgroup>
<tr height=10>
	<td align=middle><label for=addr class=info>Name or IP address of the target host</label></td>
	<td><input class=address name=addr id="addr" value="$FORM_addr" size=30 maxlength=60 align=right"></td>
	<td><input type=submit name="cmd" value="ping"></td>
</tr>
</table>
EOF

	TRUE=0
	FALSE=1
	IPV4_enabled=$FALSE
	IPv6_enabled=$FALSE
	IPv4_address="" 
	IPv6_address=""

	#first check if IPv4/Ipv6 is enabled on the system
	[ -e /proc/sys/net/ipv4 ] && IPv4_enabled=$TRUE
	[ -e /proc/sys/net/ipv6 ] && IPv6_enabled=$TRUE


#####################################################################
# just debugging stuff
#####################################################################
#echo "<pre>"
#echo $IPv4_enabled
#echo $IPv6_enabled
#echo FORM_cmd $FORM_cmd
#echo FORM_addr $FORM_addr
#echo IPv4 $IPv4_address
#echo IPv6 $IPv6_address
#echo "</pre>"
#####################################################################

	if [ "$FORM_addr" ]; then
		addresses=`nslookup_all $FORM_addr`
		for i in $addresses
		do
			echo $i | grep ':' > /dev/null 2>&1
			[ $? -eq 0 ] && IPv6_address=$i && continue
			echo $i | grep '^[0-9]' > /dev/null 2>&1
			[ $? -eq 0 ] && IPv4_address=$i 
		done
	fi

#####################################################################
# just debugging stuff
#####################################################################
#echo "<pre>"
#echo $IPv4_enabled
#echo $IPv6_enabled
#echo FORM_cmd $FORM_cmd
#echo FORM_addr $FORM_addr
#echo IPv4 $IPv4_address
#echo IPv6 $IPv6_address
#echo "</pre>"
#####################################################################

	case $FORM_cmd in 
		ping) 	echo "<pre>"
			[ $IPv4_enabled -eq 0 -a "$IPv4_address" ]  && \
				/bin/ping -c 5 $IPv4_address
			[ $IPv6_enabled -eq 0 -a "$IPv6_address" ]  && \
				/bin/ping6 -c 5 $IPv6_address
			echo "</pre>"
			;;
	esac

echo "<div id=warning>"

[ -r ./ping.blurb ] && cat ./ping.blurb
[ ! $IPv4_enabled -eq 0 -a "$IPv6_address" ] && echo IPv4 is disabled and can therefore not be tested
[ ! $IPv6_enabled -eq 0 -a "$IPv6_address" ] && echo IPv6 is disabled and can therefore not be tested
[ ! "$FORM_addr" ] && echo No address or name specified

cat -<<EOF
</div>
</div>
</form>
EOF

/var/webconf/lib/footer.sh 
?>
