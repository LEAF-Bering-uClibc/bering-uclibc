#!/usr/bin/haserl
<% title="DSL Settings"  /var/webconf/lib/preamble.sh  %>

<H1>DSL Account Settings</H1>
<p>This page allows you to manage the DSL Account settings (pppoe). 
After adding your username and password, save the configuration 
and (re)start your DSL connection.
</p>

<% # This gets the current settings 

get_settings () {
	grep "^name.*" $PPPOE_CONFFILE | sed 's/ /=/' >/tmp/$SESSIONID.vars
	grep "^maxfail.*$" $PPPOE_CONFFILE | sed 's/ /=/' >>/tmp/$SESSIONID.vars

	. /tmp/$SESSIONID.vars

	cp /tmp/$SESSIONID.vars /my.vars


	}

save_settings () {
	# get_settings must already have been called...
	sed "s|^name.*$|name \"$FORM_DSLUSER\"|" < $PPPOE_CONFFILE >/tmp/$SESSIONID.conf
	cp /tmp/$SESSIONID.conf $PPPOE_CONFFILE
	sed "s/^maxfail.*$/maxfail $FORM_MAXFAIL/" < $PPPOE_CONFFILE >/tmp/$SESSIONID.conf
	cp /tmp/$SESSIONID.conf $PPPOE_CONFFILE
	chmod +x $PPPOE_CONFFILE
	echo '#This is a pap-secrets file' > /tmp/$SESSIONID.ppp
	echo '#papname * papsecret' >> /tmp/$SESSIONID.ppp
	echo $FORM_DSLUSER   '* ' $FORM_password >> /tmp/$SESSIONID.ppp
	cp /tmp/$SESSIONID.ppp $PAP_CONFFILE
	}

start_ppp () {
	/sbin/ifdown ppp0 2>/dev/null; /sbin/ifup ppp0 1>/dev/null
	}

PPPOE_CONFFILE=/etc/ppp/peers/dsl-provider
PAP_CONFFILE=/etc/ppp/pap-secrets
get_settings

. /var/webconf/lib/validator.sh
	if [ "$FORM_cmd" = "Save" ]; then
	. /var/webconf/lib/validator.sh
	if [ "$FORM_password" != "$FORM_password2" ]; then
	echo -e "+Passwords\nPasswords do not match." | report_validation_fail
	else
	report_validation_ok
	fi
                                                                    
        # This actually makes the changes...
#	        report_validation_ok
        save_settings
        get_settings
#	        fi                                  
	fi
	if [ "$FORM_ppp_start" = "Start" ]; 
	then start_ppp
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

<h2>Account Settings</h2>
<p>Insert your DSL Username and DSL password given by your Internet
Service Provider.</p>
<table> 
<tr><td>DSL Username</td>
<td><input type=text size="30" name=DSLUSER value="<% . /tmp/$SESSIONID.vars
					[ -z "$FORM_DSLUSER" ] && FORM_DSLUSER=$name
					echo -n "$FORM_DSLUSER" %>">

<tr><td>DSL Password:</td>
<td><input type=password name=password></td>
<tr><td>Re-enter DSL Password:</td>
<td><input type=password name=password2></td>
<td>Re-enter the DSL password for verification</td></tr>
</table>

<h2>Connection attempts</h2>
<p>Define how often pppoe should try to establish a connection until it quits.
Set to "0" if pppoe should try to connect forever.</p>
<table> 
<tr><td><b>Maximal connection attempts</b></td>
<td><input type=text size="3" maxlength="5" name=MAXFAIL value="<% . /tmp/$SESSIONID.vars
					[ -z "$FORM_MAXFAIL" ] && FORM_MAXFAIL=$maxfail
					echo -n "$FORM_MAXFAIL" %>">
</td></tr>
</table>

<h2>&nbsp;</h2>

<table><tr><td><input type=submit name="cmd" value="Save"></td>
<td>Saves data to configuration files.</td></tr>
</table>
<input type=hidden name=UI value="<% echo -n $FORM_UI %>">

<h2>&nbsp;</h2>

<h1>(Re)Start your pppoe connection</h1>
<table><tr><td><input type=submit name="ppp_start" value="Start"</td>
<td>(Re)start your internet connection. This may take a minute.</td>
</tr>
</table>
</form>


<% rm /tmp/$SESSIONID.*; 
   /var/webconf/lib/footer.sh %>	
