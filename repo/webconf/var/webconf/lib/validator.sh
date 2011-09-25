# Part of the web configuration system for LEAF routers
# Copyright (C) 2004 Nathan Angelacos - Licensed under terms of the GPL
# Id: validator.sh,v 1.2 2004/11/10 22:01:16 nangel Exp 
# $Revision: 1.4 $ $Date: 2008/03/29 18:05:52 $ $Author: mats $
#
#  Functions that perform validation of web-entry
#
#  Each function should take one or more lines of data; for each line of 
#   data that does not validate, it should print the line and reason for
#   failure, in this format:   line ( reason for failure )
#   e.g.    abc.def.ggg.hhh  ( not a valid ip address )
#  If the function DOES validate, nothing should be printed.
#  An optional argument $1 is added at the end of the printout.
#  It is mainly intended for adding "<br />" for use in html-output.

#   How to use these functions:  Because the functions take multiple lines
#   they use the read command to read from stdin; so you must pipe the
#   output of something to them:   For instance:
#   + cat /etc/blah | no_blank_lines
#   echo -e "blah\nblah\n\nblah" | no_blank_lines
#    

# Colouring for visibility
# Mild colours
#CL0=FFFFE0; CL1=FFFFE8 CL2=FFFFF0; CL3=F8FFF8; CL4=F0FFFF
# Stronger colours
CL0=FFFFC0; CL1=FFFFD0 CL2=FFFFE0; CL3=F0FFF0; CL4=E0FFFF

# Prints every line, stripping DOS style CR/LF
dostounix () {
	 tr -d "\r" 
	}
	
# Prints the validation failure report. 
# The input to this function has this format:
#  +section name
#  error
#  error
#  +section name 
#  . . .
report_validation_fail () {
     echo -n "<b><font color=#cc0000>Please check errors below.  Save failed<br></font></b>"
     echo "<dl>"
     sed "s/^\([^+].*\)$/<dd><font color=#cc2200>\1<\/dd><\/font>/; s/^+\(.*\)$/<dt>\1<\/dt>/"
     echo "</dl>"
     }
                                    

# Just the mirror of report_validation_fail - doesnt' really take any arguments
report_validation_ok () {
          echo "<b><font color=#009900>Configuration files updated.</font></b>"
          }

# Change non-htmlized text into htmlized text:
to_html () {
	sed 's-\&-\&amp\;-g; s->-\&gt\;-g; s-<-\&lt\;-g; s-"-\&quot\;-g;' 
	} 

# Prints the line number if any lines are blank
no_blank_lines () {
	local count=1
	while read a; do
		local b=$( echo $a | sed "s/ 	//g")
		[ -z "$b" ] && echo "$a	 (Line $count is blank) $1"
		count=$(( $count + 1))
	done
	}

# Prints lines that are not of the form "*:*"
not_colon_separated () {
	local count=1
	while read a; do
		[ -n "$( echo $a | egrep '^:.*|^.*:$|^[^:]*$|^$' - )" ] && \
			echo "$a (line $count is invalid) $1"
	count=$(( $count + 1 ))
	done
	}
	
	
# Prints lines that do not look like ip addresses
# Requires the ipmask util
not_ip_address () {
	if [ -x /usr/bin/ipmask ]; then
		while read a; do
			if [ "$( /usr/bin/ipmask -N -i 0x$( /usr/bin/ipmask -N -x $a 2>/dev/null) 2>/dev/null)" != "$a" ]; then
				echo "$a  (invalid IP address) $1"
			fi
		done	
	else
		while read a; do
			[ -z $( echo "$a" | egrep "^$Trueipaddr$" ) ] && echo "$a (invalid IP address) $1"
		done
	fi
	}

# Prints lines that don't look like positive integers
not_an_integer () {
	local a
	while read a; do
		   [ -z $( echo $a | grep "^[0-9]*$" ) ]  && echo "$a (not an integer) $1"
	done
	}

# Prints lines that don't look like port numbers
not_a_port () {
	local a
	local m
	while read a; do
		m=$( echo "$a" | not_an_integer)
		if [ -z "$m" ]; then
			([ $a -lt 1 ] || [ $a -gt 65535 ]) && echo "$a (not a valid port number) $1"
		else
			echo $m
		fi
	done
	}	

not_an_interface () {
	local a
	local m
	m=$( /sbin/ip addr show | cut -d' ' -f2 | sed -e '/^$/d' | tr '\n' ' ')
	while read a; do
		a=$( echo $a )
		[ -z "$( echo "$m" | grep "$a" )" ] && echo "$a (not a valid interface) $1"
	done
	}

Netid='(net:)?\w+'
Fakeipaddr="[0-9]+(\.[0-9]+){3}"
Eightbits='(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])'
Trueipaddr="($Eightbits\.){3}$Eightbits"					# not_ip_address
Leasetime='([[:digit:]]+(m|h|d)|infinite)'
Fake_ip_pair="$Fakeipaddr,$Fakeipaddr"
Half_ip_pair="$Fakeipaddr(,$Fakeipaddr)?"
Extra_ip_pair="(,$Fakeipaddr){0,2}"
# Three groupings of lease ranges
Plain_dhcp_range="$Fake_ip_pair(,$Leasetime)?"				# dnsmasq.cgi
Netmasked_dhcp_range="($Fakeipaddr,){2}$Half_ip_pair(,$Leasetime)?"	# dnsmasq.cgi
Netid_dhcp_range="$Netid,$Fake_ip_pair$Extra_ip_pair(,$Leasetime)?"		# dnsmasq.cgi
# The general form of range
Valid_dnsmasq_range="($Netid,)?$Fake_ip_pair$Extra_ip_pair(,$Leasetime)?"	# not_dhcp_range
#True_dnsmasq_range="($Netid,)?$Trueipaddr,$Trueipaddr(,$Trueipaddr){0,2}(,$Leasetime)?"

Twohex='[0-9a-fA-F]{2}'
Hwaddr="$Twohex(:$Twohex|:\*){5}"
Hostname='[[:alpha:]]([[:alnum:]]*|-[[:alnum:]]+)*'
Qname="$Hostname(\.$Hostname)*"

# Main testing case
Simple_dhcp_host="$Hwaddr(,$Fakeipaddr(,$Hostname)?|,$Hostname(,$Fakeipaddr)?)?(,$Leasetime)?(,ignore)?"
#Simple_dhcp_host="$Hwaddr(,$Trueipaddr(,$Hostname)?|,$Hostname(,$Trueipaddr)?)?(,$Leasetime)?(,ignore)?"
Basic_hwaddr_ipaddr="$Hwaddr,$Fakeipaddr"	# dnsmasq.cgi

# The next regex allows hostname as well as lease time at the string end. Difficult to discribe their differences.
Mixed_hwaddr_text="$Hwaddr,$Hostname"		# dnsmasq.cgi
Mixed_hwaddr_ipaddr_text="$Hwaddr,($Fakeipaddr,$Hostname|$Hostname,$Fakeipaddr)(,$Leasetime)?"	# dnsmasq.cgi

# Prints line that are not valid for declarations of dhcp-ranges in dnsmasq,
# and optionally prints ip-addressess that do not fit the usual netmask.

not_dhcp_range () {
	local a
	local m
	while read a; do
		if [ -z $( echo "$a" | egrep "^$Valid_dnsmasq_range$" ) ]; then
			echo "$a (not a valid dhcp-range) $1"
		else
			echo "$a" | tr ',' '\n' | egrep "$Fakeipaddr" | not_ip_address "$1"
			m=$( echo -n "$a" | sed -nr "s/^$Netid,//;p" | cut -d',' -f1,2 | tr ',' '\n' | \
				sed -n 's/\.[0-9]*$//p' | uniq | wc -l | tr -d ' ' )
			if [ "$m" != "1" ]; then
				echo "$a (the range is wrong or needs a netmask wider than 24 bits) $1"
			fi
			m=$( echo -n "$a" | sed -nr "s/^$Netid,//;p" | cut -d',' -f1 )
			[ -z "$( /sbin/ip ad sh | grep "${m%.*}" )" ] \
				&& echo "$m [ in $a ] (does not match any interface within a 24 bit mask) $1"
		fi
	done
	}

not_hwaddr_dhcp_host () {
	local a
	while read a; do
		if [ -z "$( echo "$a" | egrep "^$Simple_dhcp_host$" )" ]; then
			echo "$a (is not a valid simplified dhcp-host; wrong or too complicated) $1"
		else
			m=$( echo "$a" | tr ',' '\n' | egrep "$Fakeipaddr" )
			echo -n "$m" | not_ip_address "$1"
			[ -z "$( /sbin/ip ad sh | grep "${m%.*}" )" ] \
				&& echo "$m [ in $a ] (does not match any interface within a 24 bit mask) $1"
		fi
	done
	}

not_hostname () {
	local a
	while read a; do
		if echo "$a" | egrep -vq "^$Hostname$"; then
			echo "$a (is illegal host name) $1"
		fi
	done
	}

not_host_or_qname () {
	local a
	while read a; do
		if echo "$a" | egrep -vq "^$Qname$"; then
			echo "$a (is illegal host or domain name) $1"
		fi
	done
	}
