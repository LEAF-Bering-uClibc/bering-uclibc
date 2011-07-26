#!/usr/bin/haserl
<? title="$( basename $FORM_cfg .conf)"  /var/webconf/lib/preamble.sh  ?>
<!-- $Id -->

<h1>Configuration</H1>
<p>This is a generic web interface to the lrcfg functions.  You can follow the instructions in the
Bering-uClibc Installation and User's Guides to configure your LEAF router.  The options for 
each "LEAF configuration menu" mentioned are are shown in the list below.  Click on the 
approriate link to edit the file mentioned in documentation.</p>
 
<? # This gets the current settings 

# To guess the init script, check for init.d scripts in
# the package list, and then try "real hard" to figure out what
# process to look for with the ps command.
# Credit goes to K.-P. Kirchdorfer for the suggestions on how to do this

pkg="$( basename $FORM_cfg .conf )" 

# Arne Bernin had the great idea to print the help text, with "live" links
# from the help text.  This stuff is basically his idea:
if [ -e /var/lib/lrpkg/$pkg.help ]; then
	echo "<h2>Package Help Text</h2>"
	echo "<p>"
	sed 's-http:\([^ ]*\)-(in another window) <a href=http:\1 target=newwindow>http:\1</a>-g; s-$-<br>-g;' < /var/lib/lrpkg/$pkg.help
	echo "</p>"
	fi
				   

# of course, etc is separated into net and sys; so if its etc, we cheat:
case "$pkg" in
	"etc.net" | \
	"root.net" )	service="networking"
			;;
	"etc.sys" | \
	"root.sys" )	service="sysklogd inetd"
			;;
	* )		initscript="$( grep etc/init.d/. /var/lib/lrpkg/${pkg}.list 2>/dev/null )"
			for x in $initscript; do
				service="$service $( basename ${x} )"
				done
			;;
esac

# for each service, try to figure out what the daemon is
for x in $service; do
	guess=$( grep "\-\-exec" /etc/init.d/$x | head -n 1 | \
		sed 's/^.*exec//; s/^[ 	]*//; s/\([^ 	]*\).*$/\1/; s/;//g' )
	# exec runs $DAEMON, or there is no "exec" line
	if [ "$guess" = "\$DAEMON" ] || [ -z "$guess" ]; then
		guess=$( grep "DAEMON=" /etc/init.d/$x | head -n 1 | \
			sed "s/^.*DAEMON=//" )
		fi
	[ -z "$guess" ] && guess="NULL"

	daemon="$daemon $guess"
	done

echo -e "service=\"${service}\"\ndaemon=\"${daemon}\"" >/tmp/$SESSIONID.vars
unset initscript
unset service
unset daemon

. /var/webconf/lib/validator.sh
if [ "$FORM_cmd" = "Save" ] && [ -n "$FORM_file" ]; then
	# make sure its a file we CAN save...
	if grep -q "^${FORM_file}[ |	]"  /var/lib/lrpkg/${FORM_cfg}; then
		echo "$FORM_content" | dostounix >${FORM_file}
		echo "file=\"\"" >>/tmp/$SESSIONID.vars
	        report_validation_ok
	        else
	        echo -e "+Invalid Filename\n${FORM_file} is not a valid file" | \
	        	report_validation_fail
		fi
	FORM_file=""
	fi

if [ "$FORM_cmd" = "Cancel" ]; then
		echo "file=\"\"" >>/tmp/$SESSIONID.vars
		FORM_file="";
		fi
?>


<?if  . /tmp/$SESSIONID.vars;  [ -n "${service}" ] ?>

<h1>Daemon Status</h1>
<?	# Build a form for each entry in service
       . /tmp/$SESSIONID.vars; 

	count=0
	for x in $service; do
		count=$(( $count + 1 ))
		echo "<form action=\"$SCRIPT_NAME\" method=post>"
		echo "<input type=\"hidden\" name=\"SVC\" value=\"$x\">"
		echo "<input type=hidden name=cfg value=\"$FORM_cfg\">"
		
		process="$( echo $daemon | cut -f $count -d ' ' )"
		# If we could not  get a daemon to check for pidof, then add custom
		# checks here.  Note how networking and shorewall are done;
		# 6wall, ipsec, ppp, radvd and others need to be done.
		if [ "$process" = "NULL" ]; then
			case "$x" in
				networking )	statcheck='/sbin/ip link | grep UP | grep eth0'
						;;
				webconf | \
				modutils | \
				ntpdate )	statcheck='echo up'
						;;
				keyboard )	# keyboard init doesn't know restart, so
						# we do some crazystuff here
						statcheck='echo up'
						[ "$x" = "$FORM_SVC" ]  && \
							[ "$FORM_cmd" = "Restart" ] && \
								FORM_cmd="Start"
						;;
				shorewall ) 	statcheck='echo $( /sbin/iptables -L -n | grep "Chain" |  wc -l | sed "s/ //g" ) | grep -v "^3$"'
						;;
				6wall ) 	statcheck='echo $( /sbin/ip6tables -L -n | grep "Chain" |  wc -l | sed "s/ //g" ) | grep -v "^3$"'
						;;
			esac
			fi
		[ "$x" = "$FORM_SVC" ] && a="$FORM_cmd"
		[ "$process" = "NULL" ] && process="-"
		/var/webconf/lib/svcstat.sh "$a" "${x}" "${process}" "${statcheck}"
		echo "</form>"
		
		unset process
		unset statcheck
		unset a
		done;
		?>
		<p><b>Note:</b> Restarting services that affect network connectivity (e.g. networking,
		web server or firewall rules) may cause the refresh to fail when restarting the
		service.  If this happens, you must refresh the page manually by using the
		refresh button from your browser.</p>
<?fi?>


<form action="<? echo -n $SCRIPT_NAME ?>" method=post>
<?if . /tmp/$SESSIONID.vars; [ -z "$FORM_file" ]  ?>
	<h1>Configuration Settings</h1>
	<p>The following files can be edited to change configuration settings</p>

	<table>
	<? cat /var/lib/lrpkg/${FORM_cfg} | \
		while read a b; do
		cat <<-EOF
		<tr><td>
		<a href="${SCRIPT_NAME}?cfg=${FORM_cfg}&file=${a}">
		${a}</td><td>
		${b}</td></tr>
		EOF
		done
	?>
	</table>
	<br>
	<?el?>
	<h1>Edit <? echo -n $FORM_file ?></h1>
	<?if grep -q "^${FORM_file}[ |	]"  /var/lib/lrpkg/${FORM_cfg} ?>
		<textarea cols=80 rows=20 name=content><? cat $FORM_file ?></textarea>
		<table><tr><td><input type=submit name="cmd" value="Save"></td>
		<td><input type=submit name="cmd" value="Cancel"></td></tr>
		</table>
		<?el?>
		<p><b><font color=#cc0000>That is not a file listed in the 
		configuration file list.</font></b>  You may only edit 
		configuration files from the web interface.</p>
		<?fi?>
	<?fi?>

<input type=hidden name=UI value="<? echo -n $FORM_UI ?>">
<input type=hidden name=cfg value="<? echo -n $FORM_cfg ?>">
<input type=hidden name=file value="<? . /tmp/$SESSIONID.vars; echo -n $FORM_file ?>">
</form>
<? rm /tmp/$SESSIONID.*;  /var/webconf/lib/footer.sh ?>	
