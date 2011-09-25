#!/usr/bin/haserl
<% # This is all just one big shell script because its smaller and easier to read that way.
   # Id: logfiles.cgi,v 1.4 2005/10/03 21:09:05 nangel Exp 
   # $Id: logfiles.cgi,v 1.3 2008/03/29 22:05:56 mats Exp $
   
. /var/webconf/lib/validator.sh		# Sets colours CL0 to CL4

FILTERDIR=/var/webconf/lib/filter

  FORM_name="$( echo $FORM_name | to_html | sed "s-[^/a-zA-Z\.0-9_-]--g" )"
  FORM_name_ok=$( ls -1 /var/log | grep "^$FORM_name\$" )
  
  case "$FORM_cmd" in
	"Download" )	if [ -n "$FORM_name_ok" ]; then
				cat <<-EOF
				content-type: application/octet-stream
				content-disposition: attachement; filename=$FORM_name

				EOF
				cat /var/log/$FORM_name 
				exit
				fi
			;;
	"View" )	if [ -n "$FORM_name_ok" ]; then
				title="Contents of $FORM_name" /var/webconf/lib/preamble.sh | sed "/Begin Menu/,/End Menu/D"
				cat <<-EOF
				<a href="$SCRIPT_NAME">Return to List of Logfiles</a>
				<h2>$(echo "$FORM_name" | to_html)</h2>
				EOF
			
				shorewall_table_view () {
					echo "<tr>"
					for a in Date Time Host Rule Action "In I/F" "Out I/F" "From IP" "Target IP" \
							Protocol "Src Port" "Dest Port"; do
						key=$(echo $a | tr ' //' '__')
			                        if [ x"$key" = x"$FORM_key" ]; then
							echo -n "<th>$a</th>"
							else
				echo -n "<th><a href=\"$SCRIPT_NAME?cmd=View&style=shorewall&key=$key&name=$FORM_name\">$a</a></th>"
						fi
					done
					echo "</tr>"
					sed 's-^.*##--; s-^\([A-z]*\) \+-\1\&nbsp;-;
						s-MAC=[^ ]* --g; s-LEN=.*PROTO=-PROTO=-;
						s-LEN=.*$--; s-Shorewall:--;
						s-IN= -local -; s-OUT= -local -;
						s-ID=[^ ]*--; s-SEQ=[^ ]*--g;
						s-[A-Z]*=--g; s-\([A-Z]\):-\1 -g; s-:\([A-Z]\)- \1-g;
						s- *$--; s-  *-</td><td>-g;
						s-^-<tr><td>-; s-$-</td></tr>-'
				}  # shorewall_table_view

				setpats () {
					minus_n=""
					case "$1" in

						"Date" )  
							pat1=""
							pat2="[A-Za-z]\+ \+[0-9]\+ "
							pat3=".*"
							minus_n="-n"
							;;
						"Time" )  
							pat1=".* \+"
							pat2="[0-9]\+:[0-9]\+:[0-9]\+"
							pat3=" \+[a-zA-Z0-9].*"
							minus_n="-n"
							;;
						"Host" )
							pat1=".*"
							pat2="[a-zA-Z0-9]\+"
							pat3=" Shore.*"
							;;
						"Rule" )
							pat1=".*Shorewall:"
							pat2="[^:]\+"
							pat3=":.*"
							;;
						"Action" )
							pat1=".*:"
							pat2="[A-Z]\+"
							pat3=": IN=.*"
							;;
						"In_I_F" )
							pat1=".*IN="
							pat2="[^ ]\+"
							pat3=" .*"
							;;
						"Out_I_F" )
							pat1=".*OUT="
							pat2="[^ ]*"
							pat3=" .*"
							;;
						"From_IP" )
							pat1=".*SRC="
							pat2="[^ ]\+"
							pat3=" .*"
							minus_n="-n"
							;;
						"Target_IP" )
							pat1=".*DST="
							pat2="[^ ]\+"
							pat3=" .*"
							minus_n="-n"
							;;
						"Protocol" )
							pat1=".*PROTO="
							pat2="[A-Z]\+"
							pat3=" .*"
							;;
						"Src_Port" )
							pat1=".*SPT="
							pat2="[^ ]\+"
							pat3=" .*"
							minus_n="-n"
							;;
						"Dest_Port" )
							pat1=".*DPT="
							pat2="[^ ]\+"
							pat3=" .*"
							minus_n="-n"
							;;
						* )
							pat1=".*"
							pat2=""
							pat3=""
							;;
					esac
				} # setpats

				if [ "$FORM_name" != "${FORM_name%.gz}" ]; then
					pager="zcat"
				else
					pager="cat"
				fi
			
				case "$FORM_style" in 
					"shorewall" )
						echo "<table width=100% border=1>"
						if [ "$FORM_key" = "" ]; then
							$pager /var/log/$FORM_name | shorewall_table_view
						else
							setpats $FORM_key
							$pager /var/log/$FORM_name | \
								sed "s-^\(${pat1}\)\(${pat2}\)\(${pat3}\)\$-\2##\1\2\3-" | \
								sort $minus_n | shorewall_table_view
						fi
						echo "</table>"
						;;
					* ) 	echo -e "<pre>"
						$pager /var/log/$FORM_name | to_html |
						if [ -n "$FORM_filter" ]; then
							if [ -x $FILTERDIR/${FORM_name%%.[0-9]*}.$FORM_filter ]; then
								$FILTERDIR/${FORM_name%%.[0-9]*}.$FORM_filter
							else
								echo "Not an executable filter"
							fi
						else
							cat
						fi
#						if [ -z "$FORM_filter" ]; then
#							$pager /var/log/$FORM_name | to_html;
#						else
#							$pager /var/log/$FORM_name | $FILTERDIR/$FORM_filter | to_html;
#						fi
						echo "</pre>"
						;;
				esac
				/var/webconf/lib/footer.sh
				exit
			fi
			;; # View
esac
			
title="Logfile management"  /var/webconf/lib/preamble.sh 
cat <<-EOF
<h1>Logfile bookkeeping</h1>
<p>This web page allows you to download, delete or view log files.  
If a file is marked as being in use, you can download it, but you will not be 
able to delete it.</p>
EOF

if [ "$FORM_cmd" = "Delete" ]; then
	if [ -n "$FORM_name_ok" ]; then
		echo "<h1><font color=#c02000>Notice</font></h1>"
		echo "$FORM_name was deleted."
		rm -f "/var/log/$FORM_name" 2>/dev/null 1>/dev/null
	else
		echo "You can only delete one of the log files shown below."
		echo "\"$FORM_name\" is not one of them."
	fi
fi
			
echo "<h1>Available logfiles</h1><table cellspacing=\"0\">"

# Register the log file groups
opens=$( ls -1 /var/log | sed '/.tmp/d; s/\.[0-9]\(\.gz\)\?$//' | uniq | tr '\n' ' ' )
# Log files in use by daemons
active=$( ls -l /proc/[1-9]*/fd 2>/dev/null | sed '/log/!d; s|^.*/||' | sort | tr '\n' ' ' )

echo -n "<tr align=left>"
for a in '&nbsp;&nbsp;File' "Modified" Size View Download Delete "Specialized viewing"; do
	echo -n "<th>&nbsp;$a&nbsp;</th>"
done
MM=-1 # Makes MM=0 when first used for colouring
echo "</tr>"

# Log file candidates, excepting ?tmp
ls -1 /var/log | sed '/^.tmp/d' |
while read x; do
	PRP=$( expr match "$(ls -l /var/log/$x)" '.*   \([^/]* \)' ) # Size Time; three spaces!
	in_use=$( expr match "$active" ".*$x" )
	if [ $( expr match "$opens" "$x" ) -gt 0 ]; then 
		opens=${opens#* } # Remove the already used item
		filtered=$( ls $FILTERDIR/${x%.[0-9]*}.* 2>/dev/null)
		MM=$(expr \( $MM + 1 \) % 5);  CLR=$(eval echo \$CL$MM)
		echo -n "<tr bgcolor=\"$CLR\" height=\"4\"><td colspan=\"7\"></td></tr>"
	fi
	echo "<tr bgcolor=\"#$CLR\"><td>&nbsp;$x&nbsp;&nbsp;</td>"
	echo "<td>${PRP#* }&nbsp;</td> <td align=right>&nbsp;${PRP%% *}&nbsp;</td>"
	echo "<td align=center>&nbsp;<a href=$SCRIPT_NAME?cmd=View&name=$x>view</a></td>"
	echo "<td align=center>&nbsp;<a href=$SCRIPT_NAME?cmd=Download&name=$x>download</a></td>"
	echo "<td align=center>"
	if [ $in_use = 0 ]; then
		echo "<a href=$SCRIPT_NAME?cmd=Delete&name=$x>delete</a>&nbsp;</td>"
	else
		echo "(in use)</td>"
	fi
	echo -n "<td>&nbsp;&nbsp;"
	if [ -z "${x##shorewall*}" ]; then
		echo "<a href=\"$SCRIPT_NAME?cmd=View&style=shorewall&name=$x\">formatted</a>&nbsp;"
	fi
	for fltr in $filtered; do
		if [ -x $fltr ]; then
			echo "<a href=\"$SCRIPT_NAME?cmd=View&filter=${fltr##*${x%%.[0-9]*}.}&name=$x\">${fltr##*${x%%.[0-9]*}.}</a>&nbsp;"
		fi
	done
	echo "</td></tr>"
done

echo "</table>"   

/var/webconf/lib/footer.sh %>
