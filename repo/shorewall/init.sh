#!/bin/sh

RCDLINKS="2,S19 3,S19 4,S19 5,S19 0,K91 6,K91"
SRWL=/sbin/shorewall
WAIT_FOR_IFUP=/usr/share/shorewall/wait4ifup

# parse the shorewall params file in order to use params in
# /etc/default/shorewall

if [ -f "/etc/default/shorewall" ]
then
	. /etc/default/shorewall
fi

[ "$INITLOG" = "/dev/null" ] && SHOREWALL_INIT_SCRIPT=1 || SHOREWALL_INIT_SCRIPT=0

export SHOREWALL_INIT_SCRIPT

# wait for an unconfigured interface 
wait_for_pppd () {
	if [ "$wait_interface" != "" ]
	then
           if [ -f $WAIT_FOR_IFUP ]
           then
		for i in $wait_interface
		do
			$WAIT_FOR_IFUP $i 60
		done
           else
               echo "$WAIT_FOR_IFUP: File not found"
               exit 2
           fi
	fi
}

# start the firewall
shorewall_start () {
  echo -n "Starting \"Shorewall firewall\": "
  wait_for_pppd
  $SRWL $OPTIONS start 2>&1 && echo "done."
  return 0
}

# stop the firewall
shorewall_stop () {
  echo -n "Stopping \"Shorewall firewall\": "
  if [ "$SAFESTOP" = 1 ]; then
  $SRWL $OPTIONS stop 2>&1 && echo "done."
  else
  $SRWL $OPTIONS clear 2>&1 && echo "done."
  fi      
  return 0
}

# restart the firewall
shorewall_restart () {
  echo -n "Restarting \"Shorewall firewall\": "
  $SRWL $OPTIONS start 2>&1 && echo "done."
  return 0
}

# refresh the firewall
shorewall_refresh () {
  echo -n "Refreshing \"Shorewall firewall\": "
  $SRWL refresh 2>&1 && echo "done."
  return 0
}

case "$1" in
  start)
     shorewall_start
     ;;
  stop)
     shorewall_stop
     ;;
  refresh)
     shorewall_refresh
     ;;
  force-reload|restart)
     shorewall_restart
     ;;
  *)
     echo "Usage: /etc/init.d/shorewall {start|stop|refresh|restart|force-reload}"
     exit 1
esac

exit 0
