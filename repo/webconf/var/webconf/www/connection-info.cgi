#!/usr/bin/haserl
# $Id: connection-info.cgi,v 1.5 2008/03/30 18:07:14 mats Exp $
<% title="Network Connection Status"  /var/webconf/lib/preamble.sh
	# One large script

table_wrapper () {	# $1 is masq or publ
	if [ -s $TABLEF.$1 ]
	then
		echo "<table><tr>"
		for a in Pkg Port Source Destination "Time to live" State; do
			echo -n "<th>$a</th>"
		done
		echo "</tr>"
		cat $TABLEF.$1
		echo "</table>"
		rm $TABLEF.$1
	fi
}

build_tables () {	# One snapshot for both tables

  # This sed-code was reused by <nangel> from the weblet showmasq
  cat /proc/net/ip_conntrack |\
  sed -r -e 's/^(.{3}).*[0-9][0-9]* ([0-9][0-9]*) (.*)src=(.*) dst=(.*).*sport=(.*) dport=([1-9][0-9]*) (.*)src=.*dst=(.*) sport.*$/\7 \1 \2 \4 \5 \6 \9 \8 \3 /' | \
  sort -n | 
  while read dp1 proto tm src1 dst1 sp1 dst2 state
    do
      {	{ [ $proto == tcp ] && COL=$TCPCOL; } || COL=$UDPCOL
	v_dp1=$( grep "[[:space:]]$dp1/$proto" /etc/services | cut -f1 )
	[ -n "$v_dp1" ] && dp1="$dp1/$v_dp1"
	printf "<tr bgcolor=\"$COL\"><td>&nbsp;$( echo $proto | sed 'y/tu/TU/' )&nbsp;</td>"
	printf "<td>&nbsp;at&nbsp; $dp1\t&nbsp;</td>"
	printf "<td>&nbsp;from&nbsp; $src1&nbsp;</td>"
	printf "<td>&nbsp;to&nbsp; $dst1.&nbsp;&nbsp;&nbsp;</td><td>&nbsp;$tm sec.&nbsp;</td>"
	[ -n "$state" ] && echo -n "<td>&nbsp;$state.</td>"
	echo "</tr>"
      } | \
	{ if [ $src1 == $dst2 ]; then cat >> $TABLEF.publ; else cat >> $TABLEF.masq; fi; }
    done
} # build_tables

. /var/webconf/lib/validator.sh
TCPCOL="#$CL0"; UDPCOL="#$CL4"
TABLEF=/tmp/$SESSIONID.table

cat <<-INTRO
	<h1>Network connections</h1>
	<p>
	Here the network connections into, or out from, the router
	are listed as status information. The live connections
	are split into two classes, according to their use of
	masquerading rules, or not.
	</p>
	<h1>Live connections</h1>
INTRO

build_tables	# Builds masq- and publ-tables

echo "<h2>Masqueraded connections</h2>"
table_wrapper masq

echo -e "<br/>\n<h2>Other connections</h2>"
table_wrapper publ

/var/webconf/lib/footer.sh %>
