# Part of the web configuration system for LEAF routers
# Copyright (C) 2004 Nathan Angelacos - Licensed under terms of the GPL
# $Id: widgets.sh,v 1.1 2004/10/27 20:58:11 nangel Exp $
#
# Miscellaneous functions for use in the web configuration engine
#
# Prints a 10 segment led bar vertically
# $1 is the number of elements to light up
ledvbar () {
  	local count=1
  	local array=""
  
   [ -z "$1" ] || [ $1 -gt 10 ] && exit
  	
   while [ $count -le $1 ]; do
   	[ $count -le 5 ] && array="lg $array"
   	[ $count -le 8 ] && [ $count -gt 5 ] && array="ly $array"
   	[ $count -le 10 ] && [ $count -gt 8 ] && array="lr $array"
   	count=$(( $count + 1 ))
   	done
   	
   while [ $count -le 10 ]; do
   	[ $count -le 5 ] && array="dg $array"
   	[ $count -le 8 ] && [ $count -gt 5 ] && array="dy $array"
   	[ $count -le 10 ] && [ $count -gt 8 ] && array="dr $array"
   	count=$(( $count + 1 ))
	done   

   for x in $array; do
   	echo "<img src=\"/pix/${x}.png\" height=\"8\" width=\"24\" alt=\"${x}\"><br>"
	done
	}

# Prints a 10 segment led bar horizontally
# $1 is the number of "LED's" that should be lit
ledhbar () {
  	local count=1
  	local array=""
  
   [ -z "$1" ] || [ $1 -gt 10 ] && exit
  	
   while [ $count -le $1 ]; do
   	[ $count -le 5 ] && array="$array lg"
   	[ $count -le 8 ] && [ $count -gt 5 ] && array="$array ly"
   	[ $count -le 10 ] && [ $count -gt 8 ] && array="$array lr"
   	count=$(( $count + 1 ))
   	done
   	
   while [ $count -le 10 ]; do
   	[ $count -le 5 ] && array="$array dg"
   	[ $count -le 8 ] && [ $count -gt 5 ] && array="$array dy"
   	[ $count -le 10 ] && [ $count -gt 8 ] && array="$array dr"
   	count=$(( $count + 1 ))
	done   


   for x in $array; do
   	echo -n "<img src=\"/pix/${x}.png\" height=\"24\" width=\"8\" alt=\"${x}\">"
	done
	}
	
# Calculates a percentage, for use by ledbar, 0 - 10 (0 - 100%)
# $1 is curernt value $2 is maximum value (100%)
percent () {
	local remainder=0
	[ "$(( $1 % $2 ))" -gt 4 ] && remainder=1
	echo $(( $(( $1 * 10 / $2 )) + $remainder  ))
   	}
	
