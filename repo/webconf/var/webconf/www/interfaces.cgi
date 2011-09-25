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
# $Id$
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
cat <<-EOF
<script src="interfaces.js" type="text/javascript"></script>
EOF
######################################################################
######################################################################
# insert the interface css file
######################################################################
cat <<-EOF
        <link rel="stylesheet" type="text/css" href="/interfaces.css">
EOF
######################################################################



TEMP=/tmp$SCRIPT_NAME$$

cat <<-EOF
	<form name=$SCRIPT_NAME_form action="$SCRIPT_NAME" method=post>
	<h1>Interface set up</h1>
EOF

######################################################################

  FORM_name="$( echo $FORM_name | to_html | sed "s-[^/a-zA-Z\.0-9\-_]--g" )"
  FORM_name_ok="$( ls -1 /var/log | grep "^$FORM_name\$" )"

	case "$FORM_cmd" in
	Apply | Save)	# generate the network configuration file 
			# according to the parameters
			# first copy the loopback which is always needed
			cp ${TEMPLATE_DIR}/loopback ${TEMP}
			# now for each interface 
			for i in `get_eth_interfaces ; get_wlan_interfaces`
			do
				use_dhcp=`eval echo '$'FORM_${i}_dhcp`
				is_active=`eval echo '$'FORM_${i}_active`
				use_pppoe=`eval echo '$'FORM_${i}_pppoe`
				address=`eval echo '$'FORM_${i}_addr`
				netmask=`eval echo '$'FORM_${i}_mask`
				gateway=`eval echo '$'FORM_gateway`
				
				template=${TEMPLATE_DIR}/static

				is_in_net $gateway $address $netmask && template=${TEMPLATE_DIR}/static_gateway
				if [ "$is_active" = 1 ]; then 
					if [ "$use_dhcp" = "1" ]; then  
						template=${TEMPLATE_DIR}/dhcp
					elif [ "$use_pppoe" = "1" ]; then  
						template=${TEMPLATE_DIR}/pppoe
					fi
					cat $template | sed -e s/INTERFACE/$i/ |\
					sed -e s/ADDRESS/$address/ |\
					sed -e s/GATEWAY/$gateway/ |\
					sed -e s/NETMASK/$netmask/ >> $TEMP
				fi
			done

			# to do
			# add more interface types, like bridge or stuff like the wifi
			# interfaces

			# now copy the newly created file to the config file
			cat ${TEMPLATE_DIR}/end_interfaces >> ${TEMP}
			[ "$FORM_cmd" = "Apply" ]  && /etc/init.d/networking stop > /dev/null 2>&1
			cp ${TEMP} ${CONTROL_FILE}
			rm -f ${TEMP}
			;; 
			
	"Reset")	;; # View
	esac

	if [ "$FORM_cmd" = "Apply" ]; then
		/etc/init.d/networking start > /dev/null 2>&1
		[ -f /etc/shorewall/rules ] && /etc/init.d/shorewall restart > /dev/null 2>&1
	fi

cat <<-EOF
<div id="interfaces">

<br><div id=info>
This page allows you to display and modify the various network interfaces 
of your router.
</div>

<table cellspacing=0 cellpadding=2>
<colgroup> <col width="120"><col width="120"><col width="100"><col width="80"></colgroup>
EOF

echo "<th>Interface</th><th>Address</th><th>Netmask</th>" 
	for i in `get_eth_interfaces ; get_wlan_interfaces`
	do
		is_active=0
		use_dhcp=0
		if [ "$FORM_cmd" = "Save" ]; then 
			address=`eval echo '$'FORM_${i}_addr`
			netmask=`eval echo '$'FORM_${i}_mask`
			use_dhcp=`eval echo '$'FORM_${i}_dhcp`
			use_pppoe=`eval echo '$'FORM_${i}_pppoe`
			[ "`eval echo '$'FORM_${i}_active`" = "1" ] && is_active=1
		else
			address=`get_interface_address $i`
			netmask=`get_interface_mask $i`
			get_interface_state $i && [ $? ] && is_active="1";
			uses_dhcp $i  [ $? ] &&  use_dhcp=1
			is_used_for_ppp $i  [ $? ] && use_pppoe=1
		fi

		echo "<tr height=10>"
		echo "<td align=middle><label for=\"${i}_addr\" class=info>$i</label></td>"
			echo "<td>"
				echo "<input class=address name=${i}_addr id=\"$i_addr\" size=15 maxlength=15 value=\"$address\" align=right"
				[ "$is_active" != "1" ] && echo "disabled"
				echo "></input>"
			echo "</td>"
			echo "<td>"
				echo "<input class=address name=${i}_mask id=\"$i_mask\" size=15 maxlength=15 value=\"$netmask\" align=right" 
				[ "$is_active" != "1" ] && echo "disabled"
				echo "></input>" 
			echo "</td>"
			echo "<td align=middle><label for=\"${i}_active\" class=info>activate</label></td>"
			echo "<td>"
				echo "<input type=checkbox name=${i}_active id=\"${i}_active\" value=1 onclick=toggle_active(\"$i\",this)" 
				[ "$is_active" = "1" ] && echo "checked"
				echo "></input>"
			echo "</td>"
			echo "<td align=middle><label for=\"${i}_dhcp\" class=info>use DHCP</label></td>"
			echo "<td>"
				echo "<input type=checkbox name=${i}_dhcp id=\"${i}_dhcp\" value=1 onclick=toggle_dhcp(\"$i\",this)" 
				[ "$use_dhcp" = "1" ] && echo "checked"
				[ "$use_pppoe" = "1"  -o "$is_active" != "1" ] && echo "disabled"
				echo "></input>"
			echo "</td>"
			if [ "$i" = "eth0" ];then
			echo "<td align=middle><label for=\"${i}_pppoe\" class=info>use for pppoe</label></td>"
			echo "<td align=middle>"
				echo "<input type=checkbox name=${i}_pppoe id=\"${i}_pppoe\" value=1 onclick=toggle_pppoe(\"$i\",this)" 
				[ "$use_pppoe" = "1" ] && echo "checked "
				[ "$use_dhcp" = "1"  -o "$is_active" != "1" ] && echo "disabled"
				echo "></input>"
			echo "</td>"
				if [ -r /var/webconf/www/pppoe.cgi ];then
					echo "<td align=middle>"
						[ "$use_pppoe" = "1" ] && echo "<div id=ppp_link style=display:inline>"
						[ "$use_pppoe" != "1" ] && echo "<div id=ppp_link style=display:none>"
						echo "<a href=/pppoe.cgi>"
						echo "set ppp parameters"
					echo "</a></div></td>"
				fi
			fi
		echo "</tr>" 
	done
	
	echo "<tr height=10>"
		echo "<td align=middle><label for=\"gateway\" class=info>default gateway</label></td>"
			echo "<td>"
				echo "<input class=address name=gateway id=\"gateway\" size=15 maxlength=15 align=right value=\"`get_gateway`\""
				[ "$use_pppoe" = "1" -o "$use_dhcp" = "1" ] && echo "disabled"
				echo "></input>"
			echo "</td>"
	echo "</tr>" 


	cat -<<EOF
	<tr height=10>
	<td colspan=8 align=center>
	<input type=submit name="cmd" value="Save" class=button>
	<input type=submit width=100 name="cmd" value="Reset" class=button>
	<input type=submit width=100 name="cmd" value="Apply" class=button>
	</tr>
	

</table>
<div id=warning>
EOF

[ -r ./interfaces.blurb ] && cat ./interfaces.blurb

cat -<<EOF
</div>
</div>
</form>
EOF

/var/webconf/lib/footer.sh 
?>
