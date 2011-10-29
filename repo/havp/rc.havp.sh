#!/bin/sh

RCDLINKS=" 2,S99 6,K09 "

# The location for pid file
piddir=/var/run/havp

case $1 in
start)
	mkdir -p /var/log/havp
        mkdir -p $piddir
        /sbin/havp
        echo -n "Start havp "
        ;;
stop)
        if [ -f $piddir/havp.pid ] && kill `cat $piddir/havp.pid`
	then
	        echo -n "Stop havp "
	fi
        ;;
*)
        echo "usage: havp.sh {start|stop}" >&2
        ;;
esac
