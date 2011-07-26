#!/usr/bin/haserl
# $Id: keyboard.cgi,v 1.5 2008/04/11 17:43:11 mats Exp mats $
<? title="Keyboard Map"  /var/webconf/lib/preamble.sh ?>

<? # Functions and data mining

get_settings () {
	if [ -f /etc/default/keyboard ] ; then
		KBD_CONFFILE=/etc/default/keyboard
	else
		KBD_CONFFILE=/etc/init.d/keyboard
	fi
	if [ -f $KBD_CONFFILE ]; then
		KBD_MAP=$( grep "^KEYMAP=" $KBD_CONFFILE | sed 's/KEYMAP=//; s/\"//g;' )
		KBD_DIR=$( grep "^KEYDIR=" $KBD_CONFFILE | sed 's/KEYDIR=//; s/\"//g;' )
		KBD_CHOICES=$( ls $KBD_DIR/*.map | sed "s-$KBD_DIR--; s-/--g;" )
	fi

	# and put them in a temp file
	rm -f /tmp/$SESSIONID.vars 2>/dev/null 1>/dev/null
	for a in CONFFILE MAP DIR CHOICES; do
		echo "KBD_$a=\"$( eval echo \$KBD_${a})\"" >>/tmp/$SESSIONID.vars
	done
}
	
# If cmd is "Apply", apply the change.
apply_changes () {
	# get_settings must already have been called...
	sed "s/^KEYMAP=.*$/KEYMAP=\"$FORM_KBD\"/" < $KBD_CONFFILE >/tmp/$SESSIONID.conf
	mv /tmp/$SESSIONID.conf $KBD_CONFFILE
	chmod +x $KBD_CONFFILE
	echo "<p><b>Reloading Keyboard</b></p><p>"
	$KBD_CONFFILE reload
	echo "</p>"
}

remove_extras () {
	echo "<b><p>Removing extra Keyboard Mappings</b></p><p>"
	$KBD_CONFFILE remove
	echo "</p>"
	}

. /var/webconf/lib/validator.sh
get_settings
if [ "$FORM_cmd" = "Apply" ]; then
	apply_changes
	get_settings
fi
		
if [ "$FORM_cmd" = "Remove" ]; then
	remove_extras
	get_settings
fi
. /tmp/$SESSIONID.vars
?>

<h1>Keyboard map</h1>

<p>This page allows you to change the keyboard mapping on the 
LEAF router.  If you use a non-US keyboard, you should change
the keyboard layout to reflect your local keyboard settings.  
</p>

<h1>Selection of keyboard map</h1>

<h2>Shell keyboard layout</h2>
<p>Layout used for the command shell on the router.
The setting does not affect the web interface.
</p>

<form action="<? echo -n $SCRIPT_NAME ?>" method="post"
	enctype="multipart/form-data">

<table>
<tr bgcolor="<? echo -n "#$CL0" ?>">
	<td class="fhead">Present map</td>
	<td class="ftail">
		<p>Your current keyboard map is
		<? echo -n "<u><font color=\"blue\">$KBD_MAP</font></u>"?>.</p>
		<hr />
	</td>
</tr>
<tr bgcolor="<? echo -n "#$CL3" ?>">
	<td class="fhead">New layout</td>
	<td class="ftail">
	<? if [ "$( echo $KBD_CHOICES | sed 's/ //g;')" = "$KBD_CHOICES" ]; then
		cat <<-TEXT
		<p><font color=\"#cc2200\">You only have <b>one</b> keyboard map
		on your system.  You won't be able to change the keyboard
		mapping from the currently selected layout.</font></p>
		TEXT
	else
		echo "<select name=\"KBD\" size=\"1\">"
		# . /tmp/$SESSIONID.vars
		for y in $KBD_CHOICES; do
			echo -n "<option"
			[ "$KBD_MAP" = "$y" ] && echo -n " selected "
			echo ">$y</option>"
		done
		echo "</select> Select the keyboard layout you wish to activate."
		echo "<hr />"
	fi
	?>
	</td>
</tr>
</table>

<h2>&nbsp;</h2>

<table>
<tr><td class="svb"><input type=submit name="cmd" value="Apply"></td>
	<td class="svbtext">Pressing the button will make the change take effect immediately.
	</td>
</tr>
</table>

<p>
If you need to save disk space, you can remove the unused keyboard mappings by 
<a href="<? echo -n $SCRIPT_NAME ?>?cmd=Remove">clicking here</a>. Please be 
aware that you will not be able to change your keyboard map after deleting the
extra mappings. In case of doubt, do not remove the extra mappings!
</p>

<input type=hidden name=UI value="<? echo -n $FORM_UI ?>">
</form>

<? rm /tmp/$SESSIONID.*; /var/webconf/lib/footer.sh ?>	
