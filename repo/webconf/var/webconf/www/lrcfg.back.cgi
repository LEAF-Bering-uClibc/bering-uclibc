#!/usr/bin/haserl
<%  SESSIONID=${FORM_SESSIONID:-${SESSIONID}}
   [ "$FORM_cmd" = "Backup" ] && echo "Refresh: 2; url=$SCRIPT_NAME?STAGE=1&SESSIONID=$SESSIONID"
   if [ "$FORM_STAGE" = "1" ]; then
		if ! [ -f /tmp/$SESSIONID.backup.done ]; then
			echo "Refresh: 2; url=$SCRIPT_NAME?STAGE=1&SESSIONID=$SESSIONID"
			echo "DONE=NO" >/tmp/$SESSIONID.vars
		else
			echo "DONE=YES" >/tmp/$SESSIONID.vars
		fi
	fi
title="Commit Changes to Read/Write Media"  /var/webconf/lib/preamble.sh  %>
<!-- $Id: lrcfg.back.cgi,v 1.3 2006/09/12 17:57:25 espakman Exp $ -->

<% # lrcfg.back settings
  SESSIONID=${FORM_SESSIONID:-${SESSIONID}}

 get_settings () {
	DEVF="/var/lib/lrpkg/pkgpath.disks"
	cat $DEVF 2>/dev/null | if  read dev fs; then
		echo fs=$fs >>$TEMPFILE
		echo dev=$dev >>$TEMPFILE
		fi
	}


  TEMPFILE=/tmp/$SESSIONID.vars
  touch $TEMPFILE
  
  get_settings

  case "$FORM_cmd" in
	"Backup" )
		echo "FORM_STAGE=1" >>/tmp/$SESSIONID.vars
		;;
  	* )
	  # Set the 2 databases to pre selected.
	  FORM_wc_configdb=Y
	  FORM_wc_moddb=Y
	  	;;
	 esac;
 %>

<% if SESSIONID=${FORM_SESSIONID:-${SESSIONID}};  . /tmp/$SESSIONID.vars; [ "$FORM_STAGE" = "1" ] ; then %>
<h1>Saving Packages</h1>
<% # If the command is Backup start the subshell
   SESSIONID=${FORM_SESSIONID:-${SESSIONID}}

   . /tmp/$SESSIONID.vars

   if [ "$FORM_cmd" = "Backup" ]; then
	for x in configdb moddb; do
	  	if [ "$(eval echo \$FORM_wc_${x})" ]; then
	  		name="$( grep "^${x}" /var/lib/lrpkg/backup 2>/dev/null | cut -f2 -d = )"
	  		candidate="$candidate ${name}"
	  		fi
		done

	# Empty candidate list?
	if [ -z "$candidate" ]; then
		echo '<div class="HeavyRed">No packages were selected for backup</div>' > /tmp/$SESSIONID.status
		echo "<div class=\"HeavyBlue\">Selecting Packages for backup.</div>"
		touch /tmp/$SESSIONID.backup.done
		else
		echo "<div class=\"HeavyBlue\">Will attempt to back up the following packages: $namelist</div>" >/tmp/$SESSIONID.status

		# This is the magic... we run a subshell script in the background.
		# Even when this script dies, the subshell survives.
		# We also do everything in our power to find an excuse NOT to do a
		# backup.
		(

		export PATH=/usr/sbin:/sbin:/usr/bin:/bin:$PATH
		export FS=$fs
		export DEV=$dev
		
		log () {
			if [ -n "$1" ]; then
				echo "<span class=\"Heavy${1}\">$2</span>" >>/tmp/$SESSIONID.status
				else
				echo "$1" >>/tmp/$FORM_SESSIONID.status
				fi
			}


		build_lrp () {
			# use apkg $1 to build the package in /tmp
			apkg $1 /tmp  2>&1 1>/dev/null
			if ! [ -r /tmp/$2.lrp ]; then
				log "Red" "The package was not created in /tmp!"
				return 1
				fi

			if  [ -z "$( tar tzvf /tmp/$2.lrp )" ]; then
				log "Red" "The package was empty."
				rm -f /tmp/$2.lrp
				return 1
				fi
			return 0
			}

		mount_check () {
			msg=$( mount -t "$1" "$2" $PKGDIR -o rw 2>&1)
			if [ "$?" -gt 0 ]; then
				log "Red" "$msg"
				return 1
				fi
			umount $PKGDIR >/dev/null 2>&1
			return 0
			}

		smart_copy () {
			# Yes, tmpfs is 4K blocks and floppies are .5K; but if you are so tight that
			# you only have 4K free on a diskette, you need to be using the command-line
			# interface.
			DF=$(( $( df | tail -n 1 | sed "s/ \+/ /g" | cut -f 4 -d' '  ) + 0 ))
			OLDF=$(( $( du $PKGDIR/$1.lrp | cut -f 1 ) + 0 ))
			NEWF=$(( $( du /tmp/$1.lrp | cut -f 1 ) + 0 ))
			DF=$(( $DF + $OLDF ))
			if [ $DF -lt $NEWF ]; then
				log "Red" "New Package is ${NEWF}K in size; You only have ${DF}K available."
				return 1
				fi
			log "Blue" "New Package is ${NEWF}K in size, ${DF}K is available.  Copying ..."
			cp /tmp/$1.lrp $PKGDIR/$1.lrp
			rm -f /tmp/$1.lrp
			return 0
			}

		do_backup () {
			#<apkg flag to build lrp> <package name>
			log "Blue" "Backing up package $2 ...<br>"
                        mount_check "$FS" "$DEV"
                        if [ $? -gt 0 ]; then
				log "Red" "Backup Failed<br>"
                        	return 1
                        	fi

                        build_lrp "$1" "$2"
                        if [ $? -gt 0 ]; then
                        	log "Red" "Backup Failed<br>"
                        	return 1
                        	fi

			mount -t $FS $DEV $PKGDIR -o rw 2>&1 >/dev/null
			smart_copy "$2"
			retcode="$?"
			umount $PKGDIR 2>&1 >/dev/null
			if [ "$retcode" -gt 0 ]; then
				log "Red" "Backup Failed<br>"
				return 1
				else
	                        log "Green" "Done<br>"
	                        fi
			}

		PKGDIR=/var/lib/lrpkg/mnt
		# dev and fs are sourced from the SESSIONID.vars
		for name in $candidate; do
			type="$( grep "$name\$" /var/lib/lrpkg/backup | cut -f1 -d= || "NONE" )"
			[ "$type" == "configdb" ] && flag="-o"
			[ "$type" == "moddb" ] && flag="-d"
			[ -z "$flag" ] && log "Red" "Invalid backup flag for $name"
			do_backup "$flag" "$name"
			done

		touch /tmp/$SESSIONID.backup.done ) 2>/dev/null 1>/dev/null &
		touch /tmp/$SESSIONID.script
		fi

	echo '<hr><div class="HeavyBlue"><b>Process Running.  Please wait...</b></div>'
	fi

if [ -z "$FORM_cmd" ]; then
	[ -r /tmp/$SESSIONID.status ] && cat < /tmp/$SESSIONID.status
	if [ "$DONE" = "YES"  ]; then
		rm -f /tmp/$SESSIONID.*
		echo '<hr><div class="HeavyBlue"><b>Process Complete</b></div>'
		else
		echo '<hr><div class="HeavyBlue"><b>Process Running.  Please wait...</b></div>'
		# touch /tmp/$SESSIONID.backup.done
		fi
	fi
   # If the command is blank, then let's just abort.

  /var/webconf/lib/footer.sh
%>
<% else %>
<!-- ---------------- The selection form ------------------------------->
<h1>Package Selection</h1>
<% . /tmp/$SESSIONID.vars %>
<p>This web page simulates the <code>lrcfg.backup</code> script for experienced
users.</br>Checked configuration databases will be copied to <em><% echo -n $dev %></em>.</p>

<form action="<% echo -n $SCRIPT_NAME %>" method=post>
<h1>Select Configurations</h1>
<table width=70% >
<%
  configdb_descr="System Configuration"
  moddb_descr="Kernel Modules"
  
  for x in configdb moddb; do
  	echo "<tr><td align=left>"
  	echo -n "<input name=wc_${x} type=checkbox  value=\"Y\""
  	[ "$(eval echo \$FORM_wc_${x})" ] && echo -n " checked"
  	echo ">"
  	# The name comes from /var/lib/lrpkg/backup
	echo "<td>" 
	grep "^${x}" /var/lib/lrpkg/backup 2>/dev/null | cut -f2 -d= || echo ${x}
  	echo "</td><td align=left>$( eval echo \$${x}_descr)</td>"
  	echo "</tr>"
 	done
%>
</table>
<h2></h2>
<input type=submit name=cmd value="Backup">
<input type=hidden name=STAGE value="<% echo -n $STAGE%>">
</form>

<% rm /tmp/$SESSIONID.*; /var/webconf/lib/footer.sh %>
<% fi  # End the clause for NOT in backup loop %>
