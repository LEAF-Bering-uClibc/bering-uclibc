#!/usr/bin/haserl
<? title="Edit leaf.cfg File"  /var/webconf/lib/preamble.sh  ?>
<!-- $Id -->

<h1>Boot Configuration</H1>
<p>The leaf.cfg file defines the boot-time parameters for a LEAF router. 
This file is stored on your boot device.  You should be familiar with the
the Bering-uClibc User's Guide before proceeding.  <b>Modifying this
file incorrectly can prevent your LEAF router from booting.</b></p>

<? # Get / Save the leaf.cfg file

MNT="/var/lib/lrpkg/mnt"

. /var/webconf/lib/validator.sh

get_leafcfg () {
		
	# This grabs the environment from the init process,
	# which should have the LEAFCFG variable set
	eval export $( cat /proc/1/environ | tr "\0" "\n" | grep LEAFCFG )
	}

mount_boot () {
	mount -t $type $dev $MNT 2>/dev/null 1>/dev/null
	}
	
	
umount_boot () {
	umount $MNT 2>/dev/null 1>/dev/null
	}
		
get_leafcfg
type=$(echo $LEAFCFG | cut -f2 -d':')
dev=$( echo $LEAFCFG | cut -f1 -d':')

if [ -n "$LEAFCFG" ]; then
	mount_boot
	if [ "$FORM_cmd" = "Save" ] && [ -n "$FORM_bootconfig" ]; then
		echo "<h1>Saving Updates</h1>"
		echo "$FORM_bootconfig" | tr -d "\r" > ${MNT}/leaf.cfg
		report_validation_ok
		fi

	echo "LEAFCFG=\"$LEAFCFG\"" >/tmp/$SESSIONID.vars
	echo "bootdev=\"$dev\"" >>/tmp/$SESSIONID.vars
	echo "boottype=\"$type\"" >>/tmp/$SESSIONID.vars
	[ -e ${MNT}/leaf.cfg ] && \
		cat ${MNT}/leaf.cfg >/tmp/$SESSIONID.leaf.cfg
	umount $MNT 2>/dev/null 1>/dev/null
	fi
	
 . /tmp/$SESSIONID.vars
?>	
<form action="<? echo -n $SCRIPT_NAME ?>" method=post>

<?if [ -n "$LEAFCFG" ] ?>
<h2>LEAF.CFG</h2>
<?  echo "<p>This is the leaf.cfg file from the <b>$bootdev</b> device." ?>
The web interface only allows you to change the leaf.cfg from the boot device.
If you need to create a new file on another device, you must do so through 
a ssh session or from the console.</p>

<textarea rows=20 cols=80 name=bootconfig><? cat /tmp/$SESSIONID.leaf.cfg ?></textarea>
<table><tr><td><input type=submit name="cmd" value="Save"></td>
<td><input type=submit name="cmd" value="Cancel"></td></tr>
</table>

<?el?>
<p><span class="HeavyRed"<b><u>Error</u></b></span>.  The LEAFCFG environment
variable was not found, and so we cannot find the LEAF.CFG file.</p>

<?fi?>
</form>

<? rm /tmp/$SESSIONID.*;  /var/webconf/lib/footer.sh ?>	
