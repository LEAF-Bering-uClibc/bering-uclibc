#!/bin/sh

RCDLINKS="S,S19"

test -f /bin/setserial || exit 0
test -f /etc/serial.conf || exit 0

grep -Ev '^ *(#.*)? *$' < /etc/serial.conf | while read device args
do
	/bin/setserial -z $device $args
done
