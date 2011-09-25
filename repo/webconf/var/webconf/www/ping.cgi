#!/usr/bin/haserl
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
######################################################################
# $Id: ping.cgi,v 1.1 2009/01/26 08:59:23 etitl Exp $
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
cat <<-EOF
<p>
This page  allows you to run a ping command on your firewall 
</p>
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
<colgroup> <col width="250"><col width="120"><col width="100"><col width="80"></colgroup>
<tr height=10>
	<td align=middle><label for=addr>Name or IP address of the target host</label></td>
	<td><input class=address name=addr id="addr" value="$FORM_addr" size=30 maxlength=60 align=right"></td>
	<td><input type=submit name="cmd" value="Run"></td>
</tr>
</table>
EOF

	case "$FORM_cmd" in
	Run )	# generate the network configuration file 
			# according to the parameters
			# first copy the loopback which is always needed
			echo "<pre>"
			/bin/ping -c 5 $FORM_addr 
			echo "</pre>"
			;; 
			
	esac

echo "<div id=warning>"

[ -r ./ping.blurb ] && cat ./ping.blurb

cat -<<EOF
</div>
</div>
</form>
EOF

/var/webconf/lib/footer.sh 
?>
