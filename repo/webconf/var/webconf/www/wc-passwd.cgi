#!/usr/bin/haserl
<% title="Change Webconf Password"  /var/webconf/lib/preamble.sh %>

<H1>Webconf Password</H1>
<p>This page allows you to change the username and password used to 
access these web pages.  The web interface uses <i>basic authentication</i>.  
This is the same authentication used by most SOHO routers.  While
it provides some protection, please note that the passwords are sent over the 
network in cleartext.</p>


<% # This gets the current settings 

# If cmd is "Apply", apply the change.
apply_changes () {
	. /var/webconf/lib/validator.sh
	if [ "$FORM_password" != "$FORM_password2" ]; then
		echo -e "+Passwords\nPasswords do not match." | report_validation_fail
		else
		rm /var/webconf/www/.htpasswd 2>/dev/null >/dev/null
		if [ -n "$FORM_username" ]; then
			echo $FORM_username:$( /usr/bin/pwcrypt $FORM_password 2>/dev/null) > /var/webconf/www/.htpasswd
			fi
		report_validation_ok
		fi
	}

if [ "$FORM_cmd" = "Apply" ]; then
	echo "<h1>Status</h1>"
	apply_changes
	fi
%>

<h1>Select Username and Password</h1>
<form action="<% echo -n $SCRIPT_NAME %>" method=post>

<table> 
<tr><td>Username:</td>
<td><input type=text colums=8 name=username></td>
<td>To completely disable authentication, leave both username and password blank.</td></tr>
<tr><td>Password:</td>
<td><input type=password colums=8 name=password></td>
<td>Only the first 8 characters of the password are used.</td></tr>
<tr><td>Re-enter Password:</td>
<td><input type=password colums=8 name=password2></td>
<td>Re-enter the password for verification</td></tr>
</table>


<h2>&nbsp;</h2>

<table><tr><td><input type=submit name="cmd" value="Apply"></td>
<td>Pressing the Apply button will make the change take effect immediately, but in RAM only.
<font color=#ff2200>You will need to use the Backup Packages
option to save webconf.lrp to make the change permanent.</font></td></tr>
</table>
</form>

<%  /var/webconf/lib/footer.sh %>	
