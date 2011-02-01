#!/bin/sh
#
#GPL2 -- Dave Cinege <dcinege@psychosis.com>
#

qt () { "$@" >/dev/null 2>&1 ; }

OIFS=$IFS


usage () {
	echo "Usage: $(basename $0) [-f] [-a[-w]] <basename>"
	echo "	-f: force	Force. ALL current links of <basename> are deleted."
	echo "	-a: all		Process all files in /etc/init.d/. <basename> ignored."
	echo "	-w: wipe 	Wipe /etc/rc?.d/ directories (implies -f)"
	echo "	-v: verbose	Be extra verbose."
	echo ""
	echo "This program uses 'RCDLINKS=' found in the /etc/init.d/ files."
	echo "Comment out 'RCDLINKS=' if you want a file to be ignored."
}

while getopts fawv opt ; do
	case "$opt" in
		f) rcdforce="yes" ;;
		a) rcdall="yes" ;;
		w) rcdwipe="yes"  ;;
		v) rcdvb="yes"  ;;
	esac
done

shift $(($OPTIND - 1))
	
if [ "$rcdall" = "yes" ]; then
	if [ "$rcdwipe" = "yes" ]; then
		for d in /etc/rc?.d; do
			[ ! -d "$d" ] && continue
			qt rm $d/[KS][0-9][0-9]*
		done
	fi
	F=/etc/init.d/*
else
	[ "$1" = "" ] && usage && exit 1	
	F=/etc/init.d/$1
		
	if [ ! -x "$F" ]; then
		echo "$F does not exist or is not executable."
		exit 1
	fi
fi

for f in $F; do
		
	[ ! -x "$f" ] && continue
				
	eval RCDLINKS=$(sed -n '1,/^RCDLINKS=/s/^RCDLINKS=\(.*\)/\1/p' $f 2>/dev/null)
	
	if [ "$RCDLINKS" != "" ]; then
		bf="$(basename $f)"
				
		qt ls /etc/rc?.d/[KS][0-9][0-9]$bf
		if [ $? -eq 0 ]; then
			if [ "$rcdforce" = "yes" ]; then
				qt rm /etc/rc?.d/[KS][0-9][0-9]$bf
			else
				echo "System startup links for $f already exist."
				continue
			fi
		fi
				
		for l in $RCDLINKS; do
			IFS=','; set -- $l; IFS=$OIFS
			[ ! -d "/etc/rc$1.d" ] && continue	# Ignore bad dirs.
			[ "$rcdvb" ] && echo "RCDLINKS=$RCDLINKS - $f"
			ln -sf "../init.d/$bf" "/etc/rc$1.d/$2$bf" 2>/dev/null
		done
	else
		[ "$rcdvb" ] && echo "'^RCDLINKS=' not found in $f. File ignored."
	fi
done
