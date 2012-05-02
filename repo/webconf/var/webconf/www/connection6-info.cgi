#!/usr/bin/haserl
<% title="IPv6 Network Connection Status"  /var/webconf/lib/preamble.sh
	# One large script

table_wrapper () {	# $1 is masq or publ
	if [ -s $TABLEF.$1 ]
	then
		echo "<table><tr>"
		for a in Pkg Port Source Destination State; do
			echo -n "<th>$a</th>"
		done
		echo "</tr>"
		cat $TABLEF.$1
		echo "</table>"
		rm $TABLEF.$1
	fi
}

build_tables () {

#grab ipv6 connections from nf_conntrack and store relevant information
 cat /proc/net/nf_conntrack | grep ipv6 |\
  awk '{if ($3 == "tcp") {
  proto = $3;
  state = $6;
  source = substr($7,5,length($7));
  destination = substr($8,5,length($8));
  dport = substr($10,7,length($10));}
  else {
  proto = $3;
  state="none";
  source = substr($6,5,length($6));
  destination = substr($7,5,length($7));
  dport = substr($9,7,length($9));}
  print(proto " " state " "  source " " destination " " dport) > "/tmp/tmp.6conn";
  }'

# write stored information into table fields
if [ -e /tmp/tmp.6conn ]; then
	more /tmp/tmp.6conn  | \
	while read str; do 
		var=$(echo $str | awk -F" " '{print $1,$2,$3,$4,$5}')
		set -- $var
 		dport=$5
 		state=$2
	 	if [ $state = "none" ]; then state=" "; fi
	        { { [ $1 == tcp ] && COL=$TCPCOL; } || COL=$UDPCOL
		v_dp1=$( grep "[[:space:]]$dport/$1" /etc/services | cut -f1 )
		[ -n "$v_dp1" ] && dport="$dport/$v_dp1"
		printf "<tr bgcolor=\"$COL\"><td>&nbsp;$( echo $1 | sed 'y/tui/TUI/' )&nbsp;</td>"
		printf "<td>&nbsp;at&nbsp; $dport\t&nbsp;</td>"
		printf "<td>&nbsp;from&nbsp; $3&nbsp;</td>"
		printf "<td>&nbsp;to&nbsp; $4&nbsp;&nbsp;&nbsp;</td>" 
		echo -n "<td>&nbsp;$state</td>"
		echo "</tr>"
		} | cat >> $TABLEF.publ 
    	done

	#cleanup
	rm /tmp/tmp.6conn 

fi

} # build_tables

. /var/webconf/lib/validator.sh
TCPCOL="#$CL0"; UDPCOL="#$CL4"
TABLEF=/tmp/$SESSIONID.table

cat <<-INTRO
	<h1>IPv6 Network connections</h1>
	<p>
	Here the IPv6 network connections into, or out from, the router
	are listed as status information. 
	</p>
	<h1>Live connections</h1>
INTRO

build_tables	# Builds masq- and publ-tables

table_wrapper publ

/var/webconf/lib/footer.sh %>
