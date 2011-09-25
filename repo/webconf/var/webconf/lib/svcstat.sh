#!/bin/sh 
# Generic start / stop / restart button handler for webconf services
# Part of the web configuration system for LEAF routers
# Copyright (C) 2004 Nathan Angelacos - Licensed under terms of the GPL
# $Id: svcstat.sh,v 1.2 2008/04/04 09:36:43 mats Exp mats $
# takes 3 parameters:

# cmd (start|stop|restart)
# service name  (in /etc/init.d) to call to start/stop service
# process name to check pidof to see if the service is running
#   optionally, if process name is -, then the 5th param is the 
#   command to run to check if the process is running.  The command should
#   print some value if the process *is* running.   
#   (e.g. 'ip link show | grep UP | grep eth0') to check if networking is 
#   running (or pidof dhcpcd, if using dhcp)

# e.g. svcstat.sh start ipsec509 starter

export PATH=$PATH:/usr/sbin:/sbin

cmd=$( echo $1 | tr A-Z a-z )
svc=$2
pidchk=$3
mycheck='/bin/pidof $( echo $pidchk | sed -e "s/.*\/\([^.]*\)\$/\1/g")'
[ $pidchk = "-" ] && mycheck=$4

#echo -e "<h1>Status</h1>\n<p>\n"

if [ $# -lt 2 ]; then
  cat <<-EOF
	<font color=#c00000><b>
	Webconf error!</b>  The developer that wrote this webconf forgot to give
	the correct parameters to the start / stop / restart service call.
	This is a critical error, and needs to be fixed.   
	</font></p>
	EOF
	exit 255
  fi


if ( [ "$cmd" = "start" ] || [ "$cmd" = "stop" ] || [ "$cmd" = "restart" ]); then
	echo -e "Running "$cmd" command ...\n<pre>"
	/etc/init.d/$svc $cmd
	echo  "</pre>"
	fi
	
# handle start failure
if ( [ "$cmd" = "start" ] || [ "$cmd" = "restart" ] ); then 	
	if ! test "$( eval $mycheck )"; then
		cat <<-EOF
		<pre>
		The command failed.  Usually this is due to an
		error in the configuration file.
		</pre>
		EOF
		fi
	fi
	
	
# Finally, we print the buttons
process=$( eval $mycheck )
echo "<p id='stat'>$svc is: "
if [ -n "$process" ]; then
	cat <<-EOF
	<b>running</b>
 	<input type=submit name=cmd value="Stop">
 	<input type=submit name=cmd value="Restart">
 	<input type=submit name=cmd disabled value="Start">
	EOF
	else
	cat <<-EOF
	<b>stopped</b>
 	<input type=submit name=cmd disabled value="Stop">
 	<input type=submit name=cmd disabled value="Restart">
 	<input type=submit name=cmd value="Start">
	EOF
	fi
echo '</p>'
#cat <<-EOF
#</p>
#<p>This process runs as a service.  When you make and save changes, the 
#
#configuration files for the service are changed.  However, the changes
#will not be <i>applied</i> until you restart the service.
#</p>
#EOF

