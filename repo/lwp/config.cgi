#!/usr/bin/haserl 
<% title="Backup Defaults"  /var/webconf/lib/preamble.sh  %>

<H1>Backup Defaults</H1>
<p>This page allows you to manage the backup default setting. 
You can turn off "write confirmation". With the setting turned off, configuration backup will be faster. It 
is recommended to only switch it off, if you are shure you do have 
enough space on your storage media. Otherwise leave it "On".
</p>

<%
# This get the settings
get_settings () {
	grep "^CWRT.*=.*$" $BD_CONFFILE >>/tmp/$SESSIONID.vars
	. /tmp/$SESSIONID.vars
	}

save_settings () {
	# get_settings must already have been called...
	sed "s/^CWRT=.*$/CWRT=$FORM_CWRT/" < $BD_CONFFILE >/tmp/$SESSIONID.conf
	cp /tmp/$SESSIONID.conf $BD_CONFFILE
	chmod +x $BD_CONFFILE
	}
	
BD_CONFFILE=/etc/config.cfg
get_settings

. /var/webconf/lib/validator.sh
if [ "$FORM_cmd" = "Save" ]; then
#	echo "+SSH Port" >>/tmp/$SESSIONID.err
#	echo $FORM_PORT | not_a_port >>/tmp/$SESSIONID.err
		
#	if [ -n "$( cat /tmp/$SESSIONID.err | grep -v "^+" )" ]; then
#	        report_validation_fail < /tmp/$SESSIONID.err
#	        else
	        # This actually makes the changes...
	        report_validation_ok
	        save_settings
	        get_settings
#	        fi                                  
	fi
%>


<form action="<% echo -n $SCRIPT_NAME %>" method=post enctype="multipart/form-data">

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

<h2>Write confirmation before saving</h2>
<p>If set to "ON", you'll be asked for a write confirmation 
before the configuration files are actually saved to the storage media.
The file size and available size are shown, so you can decide to abort backup,
if you don't have enough space on your storage media.</p>
<table> 
<tr><td><b>Write Confirmation (ON/OFF)</b></td>
<td><input type=text name=CWRT value="<% . /tmp/$SESSIONID.vars
					[ -z "$FORM_CWRT" ] && FORM_CWRT=$CWRT
					echo -n "$FORM_CWRT" %>">
</td></tr>
</table>

<h2>&nbsp;</h2>

<table><tr><td><input type=submit name="cmd" value="Save"></td>
<td>Saves data to configuration files.</td></tr>
</table>
<input type=hidden name=UI value="<% echo -n $FORM_UI %>">
</form>

<% rm /tmp/$SESSIONID.*; 
   /var/webconf/lib/footer.sh %>	
