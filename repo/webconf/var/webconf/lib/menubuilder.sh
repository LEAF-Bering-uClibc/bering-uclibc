#!/bin/sh
# Builds a menu based on the /etc/webconf/*.webconf files
# Part of the web configuration system for LEAF routers
# Copyright (C) 2004 Nathan Angelacos - Licensed under terms of the GPL
# $Id: menubuilder.sh,v 1.3 2004/11/16 20:57:51 nangel Exp $

build_menu () {
	# $1 is the menu class 
	# menu classes built into webconf are "expert", "basic" and "all" 
	# but there's nothing here to prevent other menu classes

	# echo "<!$(ls /etc/webconf/* | wc -c )->"

	# Get all the webconfs and put the family as the first parameter
	# Then sort them (numerically)
	cat /etc/webconf/*.webconf | sed "s/ /_/g; s/:/ /g; /^#/d" | \
		while read a b c; do
			[ "$a" = "displayname" ] && friendly=$b
	               	[ "$a" = "$1" ] && echo "${friendly} $b $c"
	               	[ "$a" = "all" ] && echo "${friendly} $b $c"
	        	done | \
	sort -n	| \
		sed "s/^[0-9]*/ /g; s/ [0-9]*/ /g" | \
		while read a b c; do
			# and print the menu out
			[ "$a" != "$family" ] && [ -n "$family" ] && echo "</div>"
			if [ "$a" != "$family" ]; then
				echo -n "<div class=\"MenuHead\">"
				echo "$( echo "${a}" | sed 's-_- -g;')</div>"
				echo "<div class=\"MenuItem\">"
				family=$a;
				fi
			if [ "$a" = "$family" ]; then
				echo -n "<a href=\""
				echo -n "$c"| sed 's-_- -g; s-^\([^/]\)/.*/-\1-;'
				echo -n "\">"
				echo -n "$b" | sed "s/_/ /g"
				echo "</a><br>"
				fi
			done
		
		echo "</div>"
		                                
	}


# Grab all the .conf files from /var/lib/lrpkg and make 
# generic menus out of them.  This lets us have instant
# "web-configuration" when we don't have a specific
# web interface for a package.	
build_lrcfg_menu () {
	
	cat <<-EOF
	<div class="MenuHead">Configuration</div>
	<div class="MenuItem">
	EOF
	
	# Its a Bering-uClibc box
	[ -f /var/lib/lrpkg/etc.net.conf ] && weird_lrp=etc
	
	# Its a classic Bering box
	[ -f /var/lib/lrpkg/root.net.conf ] && weird_lrp=root
	
	if [ -n "$weird_lrp" ]; then
		cat <<-EOF
		<a href="/lrcfg.cgi?cfg=${weird_lrp}.net.conf">
		Networking</a><br>
		<a href="/lrcfg.cgi?cfg=${weird_lrp}.sys.conf">
		System</a><br>
		EOF
		fi
		
	# get all the .confs (etc.sys.conf and etc.net.conf are special)
	candidates="$( ls /var/lib/lrpkg/*.conf | \
			sed "/etc\.net\.conf/d; /etc\.sys\.conf/d; \
			s-/var/lib/lrpkg/--g;" | \
			sort)"
	for x in $candidates; do
		echo "<a href=\"/lrcfg.cgi?cfg=${x}\">$( basename ${x} .conf )</a><br>"
		done
	
	echo "</div>"	
	}
	
build_dot_line () {
	# Nonbreaking line to keep menu minimum size
	echo "<pre>................</pre>"
	}

switch_modes_menu () {
	echo '<div class="MenuHead">Interface Style</div>'
	echo '<div class="MenuItem">'
	ifaces=$menu_sets
	for menu in $menu_sets; do
		if [ "$menu" != "$1" ]; then
			echo "<a href=\"/index.cgi?UI=$menu\">switch to ${menu}</a>"
			fi
		done
	echo '</div>'
	}

# Figure out what modes are defined by the webconf files
get_all_menu_sets () {
	echo $( cat /etc/webconf/*.webconf | \
		sed "s/ /_/g;  /^#/d; /^[ 	]*$/d; /^displayname/d; /^all/d" | \
		cut -f1 -d':' | sort | uniq )	
	}
	


# Main start

mode=${1:-"basic"}
menu_sets=$( get_all_menu_sets )

#if basic isn't listed, use the first available
# and try to inform our friends that UI has changed.
if [ -z "$( echo $menu_sets | grep "$mode" )" ]; then
	mode=$( echo "$menu_sets" | cut -f1 -d" " )
	UI=$mode
	fi

if [ "$mode" = "expert" ]; then
	build_lrcfg_menu
	fi

build_menu $mode

build_dot_line

#If we don't have any other menu-sets, don't print the switch interface line
if [ -n "$(echo $menu_sets | grep " ")" ]; then
	switch_modes_menu "$mode"
	fi
	
