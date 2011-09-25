#!/usr/bin/haserl
# $Id
<% title="General Health"  /var/webconf/lib/preamble.sh
	# More details?
	[ "$FORM_UI" == expert -o "$FORM_MORE" == yes ] && simple=no
%>
	

<h1>General state of&nbsp; "<% echo -n "$(hostname)" %>"</h1>
<p>This is a fairly detailed overview of the running system, as reported
by internal system services. 
As your experience grows, you can gather much information out of these
bits and pieces.
</p>

<h1>Identity</h1>
<h2>System</h2>
<!--	<td><b><% uname -a | cut -d' ' -f2 %></b>: -->
<p><% uname -a | cut -d' ' -f1,3- %></p>

<h2>Uptime</h2>
<p>
<% TIMECAST="At $(date | cut -d' ' -f1,2) \\1 up since \\2"
uptime | \
sed -r "s/^ *(\w.*)up (.*), load.*$/$TIMECAST/; /[0-9]$/ s/.*/& hours/"
%>
</p>

<h2>Load averages</h2>
<p><% uptime | sed 's/.*rage: //' %></p>

<h1>Networking</h1>

<h2>Interface status</h2>
<table border="0">
<% /sbin/ip addr sho | 
	sed -r 's/</\&lt;/; s/>/\&gt;/; s/^[[:digit:]]+: //; 2,$ {/^[[:graph:]]/ i\
<tr><td></td></tr>
}; s,^([[:graph:]]*)[[:space:]]*(.*),<tr><td><b>\1\&nbsp;</b></td><td>\2</td></tr>,'
%>
</table>

<h2>Routes</h2>
<table border="0">
<%
	/sbin/ip route sh |
	sed -r 's,^([[:graph:]]+) (.*),<tr><td><b>\1</b>\&nbsp;</td><td>\2</td></tr>,'
%>
</table>

<h1>System resources</h1>

<h2>Graphical summary</h1>
<div class="push">
<table><tr><th nowrap>Filesystem Utilization</th>
  <th>&nbsp;&nbsp;&nbsp;</th>
  <th nowrap>Memory Utilization</th></tr>
  <tr><td>
	<table>
		<% # File System Utilization
		. /var/webconf/lib/widgets.sh

		echo "$( df | grep -v Filesystem | sed "s/ \+/ /g" | cut -f 2,3,5,6 -d' ')" | \
		while read a b c d; do
			echo "<tr><td align=right valign=middle>$d</td><td valign=middle nowrap>"
			ledhbar $( percent $b $a )
			echo "</td><td valign=middle>$c</td></tr>"
		done
		%>
	</table></td>
  <td></td>
  <td align=center nowrap valign=middle>
	<% # Memory Free 
	. /var/webconf/lib/widgets.sh
	echo "$( free | sed -n "/^Mem:/s/ \+/ /gp" | cut -f 2,3 -d ' ' )" | \
	while read a b ; do
		ledhbar $( percent $b $a )
		echo "<br>(using $b of $a bytes)"
	done
	%>
  </td></tr>
</table>
</div>

<h2>File system usage</h2>
<div class="push">
<table class="fsmu">
<% FT="th" ; df -h | tr -s ' ' |
	while read rowtext; do
		set $rowtext
		echo -n "<tr>"
		for n in 1 2 3 4 5 6; do
			echo -n "<$FT>$(eval echo \$$n)</$FT>"
		done
		echo "</tr>"
		FT="td"
	done
%>
</table>
</div>

<h2>Memory capacity</h2>
<div class="push">
<table class="fsmu">
<% FT="th" ; free | tr -s ' ' | sed -e 's/total/_ total/' \
                -e 's^-/+ \(.*\):^-/+\&nbsp;\1: _^' |
        while read rowtext; do
                set -- $rowtext
                echo -n "<tr>"
                FU="th"
                for n in 1 2 3 4 5 6; do
                        echo -n "<$FU>$(eval echo \$\{$n#_\})</$FU>"
                        FU=$FT
                done
                echo "</tr>"
                FT="td"
        done
%>
</table>
</div>

<h1>System characteristics</h1>

<%  [ "$simple" != "no" ] && \
	cat <<-TEXT
	<p>More detailed information on processes and modules is stated in
	the <a href="/general-info.cgi?MORE=yes">expert</a> edition of
	this page.</p>
	TEXT
%>

<h2>Running processes</h2>
<div class="push">
<table class="syschr">
<%
	TDH () {
		echo -n "<$1>$2</$1>"
		}

	echo -n "<tr>"
	for nn in Pid Uid VSZ Stat Command; do
		TDH "th" "$nn"
	done
	echo "<tr>"
	if [ "$simple" == no ]; then
		ps w
	else
		ps 
	fi |
	sed -r '1d; s/ {3,}/  /g; s/^ *//; s/SW/_ SW/' |
	while read row; do
		echo -n "<tr>"
		TDH "td" "${row%% *}"
		TDH "td" "$(echo -n "$row" | cut -d' ' -f2)"
		TDH "td" "$(echo -n "$row" | cut -d' ' -f4 | tr -d '_')"
		row="$(echo -n "$row" | cut -d' ' -f5-)"
		TDH "td" "$(echo -n "$row" | cut -b 1,2,3)"
		TDH "td" "$(echo -n "$row" | cut -b 4-)"
		echo "</tr>"
	done
%>
</table>
</div>

<h2>Loaded kernel modules</h2>
<div class="push">
<table class="syschr">
<%
	echo -n "<tr>"
	for nn in Module Size "Used by"; do
		TDH "th" "$nn"
	done
	echo "</tr>"
	#/sbin/lsmod | sed -r '1d; s/\[.*\]//; s/[[:space:]]{2,}/ /g' |
	/sbin/lsmod | sed -r '1d; s/[[:space:]]{2,}/ /g' |
	if [ "$simple" == no ]; then
		cat
	else
		sed 's/\[.*\]//'
	fi |
	while read row; do
		echo -n "<tr>"
		TDH "td" "${row%% *}"
		row="${row#* }"
		TDH "td" "${row%% *}"
		TDH "td" "${row#* }"
		echo "</tr>"
	done
%>
</table>
</div>

<h2>Processor parameters</h2>
<div class="push">
<table class="syschr">
<% cat /proc/cpuinfo |
	while read row ; do
		[ -z "$row" ] && continue
		echo -n "<tr>"
		TDH "td" "${row%:*}"
		TDH "td" " : "
		TDH "td" "${row#*:}"
		echo "</tr>"
	done
%>
</table></div>

<% /var/webconf/lib/footer.sh %>	
