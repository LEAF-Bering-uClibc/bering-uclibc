#!/usr/bin/haserl --upload-limit=10
# $Id: dropbear.cgi,v 1.6 2008/04/04 09:32:58 mats Exp mats $
<% title="Dropbear SSH Server"  /var/webconf/lib/preamble.sh  %>

<h1>Dropbear Server</h1>
<p>This page allows you to manage the Dropbear SSH server. The server 
arranges secure and encrypted communication
from a remote terminal to the router.
</p>

<% 
get_settings () {
	grep "^DB_.*=.*$" $DB_CONFFILE >/tmp/$SESSIONID.vars
	. /tmp/$SESSIONID.vars
	}

save_settings () {
	# get_settings must already have been called...
	sed "s/^DB_PORT=.*$/DB_PORT=\"$FORM_PORT\"/" < $DB_CONFFILE >/tmp/$SESSIONID.conf
	mv /tmp/$SESSIONID.conf $DB_CONFFILE
	chmod +x $DB_CONFFILE
	}
	
DB_CONFFILE=/etc/default/dropbear
get_settings

. /var/webconf/lib/validator.sh
if [ "$FORM_cmd" = "Save" ]; then
	if [ -n "$FORM_pubkey" ]; then
		# They uploaded a public key
		if [ -e /root/.ssh/authorized_keys ]; then
			error="You already have a key installed."
			fi
		if [ "$(cat $FORM_pubkey | wc -l)" -ne 1 ]; then
			error="The file does not look like a single public key."
			fi
		if [ $( egrep -q "^ssh-(rsa|dss)" $FORM_pubkey ) ]; then
			error="The file does not look like a public key."	
			fi
		if [ -n "$error" ]; then
			echo "+Client Keys" >>/tmp/$SESSIONID.err
			echo "$error" >>/tmp/$SESSIONID.err
		else	
			mkdir /root/.ssh 2>/dev/null
			chmod 700 /root/.ssh
			mv $FORM_pubkey /root/.ssh/authorized_keys
			chmod 600 /root/.ssh/authorized_keys
			fi
		fi
				
	
	echo "+SSH Port" >>/tmp/$SESSIONID.err
	echo $FORM_PORT | not_a_port >>/tmp/$SESSIONID.err
		
	if [ -n "$( cat /tmp/$SESSIONID.err | grep -v "^+" )" ]; then
	        report_validation_fail < /tmp/$SESSIONID.err
        else
	        # This actually makes the changes...
	        report_validation_ok
	        save_settings
	        get_settings
        fi                                  
	fi
%>

<form action="<% echo -n $SCRIPT_NAME %>" method="post"
	enctype="multipart/form-data">

<h1>Configuration</h1>
<% if [ "$FORM_cmd" = "List" ]; then
	cat <<-EOF
	<!-- 
	#BEGIN WEBCONF SETTINGS LIST 
	$( cat /tmp/$SESSIONID.vars )
	#END WEBCONF SETTINGS LIST 
	-->
	EOF
	fi
%>

<h2>Client keys</h2>
<table>
<tr bgcolor="#FFFFD0">
<td class="fhead">Public key</td>
<td class="ftail">
<% if [ ! -e /root/.ssh/authorized_keys ] 2>/dev/null %>
<% then %>
	<p>You must have the root password to log in to the router using ssh,
	but you cannot change the password until you have successfully logged in.
	The calamity can be resolved by uploading a public key, which is then
	used for public-key authentication and to properly log in to the router.
	</p>
	<p>This interface allows you to upload <b>one</b> public key
	to the router. The file containing a public key is typically
	named&nbsp; <i>id_rsa.pub</i> &nbsp;or&nbsp; <i>id_dsa.pub</i>.
	</p>
	<p><input type=file name="pubkey"></p>
<% else %>
	<p>At least one ssh key already exists on this system. For this reason the
	web page interface for uploading a public client side key to the ssh server
	has been disabled. Any change of this key must now be done directly from
	within an ssh session.
	</p>
<% fi %>
<hr /> </td>
</tr>
</table>

<h2>SSH port</h2>
<table> 
<tr bgcolor="<% echo -n $CL3 %>">
	<td class="fhead">Listening port</td>
	<td class="ftail">
		<p>Dropbear normally listens on port 22, but should it be desirable,
		you can change this number to any other unused port.
		</p>
		<input type="text" name="PORT" value="<% . /tmp/$SESSIONID.vars
					[ -z "$FORM_PORT" ] && FORM_PORT=$DB_PORT
					echo -n "$FORM_PORT" %>">
	<hr />
	</td>
</tr>
</table>

<h2>&nbsp;</h2>

<table><tr><td class="svb"><input type="submit" name="cmd" value="Save"></td>
<td class="svbtxt">Save configuration data. To apply the changes,
you must restart dropbear after saving them.
</td></tr>
</table>
<input type="hidden" name="UI" value="<% echo -n $FORM_UI %>">

<h1>Daemon status</h1>
<% /var/webconf/lib/svcstat.sh "$FORM_cmd" dropbear dropbear %>
</form>

<% rm /tmp/$SESSIONID.*; 
   [ -e "$FORM_pubkey" ] && rm "$pubkey"
   /var/webconf/lib/footer.sh %>	
