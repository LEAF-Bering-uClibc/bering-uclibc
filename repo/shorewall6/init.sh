#!/bin/sh
RCDLINKS="2,S19 3,S19 4,S19 5,S19 0,K91 6,K91"
SRWL=/sbin/shorewall6
WAIT_FOR_IFUP=/usr/share/shorewall6/wait4ifup
VERBOSE=

# parse the shorewall params file in order to use params in
# /etc/default/shorewall
if [ -f "/etc/default/shorewall6" ]
then
        . /etc/default/shorewall6
        fi
        
# wait for an unconfigured interface 
wait_for_pppd () {
	if [ "$wait_interface" != "" ]
	then
		for i in $wait_interface
		do
			$WAIT_FOR_IFUP $i 90
		done
	fi
}

# start the firewall
shorewall6_start () {
  echo -n "Starting \"Shorewall6 firewall\": "
  wait_for_pppd
  $SRWL $OPTIONS start 2>&1 && echo "done." || echo_notdone
  return 0
}

# stop the firewall
shorewall6_stop () {
  echo -n "Stopping \"Shorewall6 firewall\": "
      $SRWL $OPTIONS clear 2>&1 && echo "done." || echo_notdone
    return 0
}

# restart the firewall
shorewall6_restart () {
  echo -n "Restarting \"Shorewall6 firewall\": "
  $SRWL $OPTIONS restart 2>&1 && echo "done." || echo_notdone
  return 0
}

# refresh the firewall
shorewall6_refresh () {
  echo -n "Refreshing \"Shorewall6 firewall\": "
  $SRWL $OPTIONS refresh 2>&1 && echo "done." || echo_notdone
  return 0
}

# status of the firewall
shorewall6_status () {
  $SRWL $SRWL_OPTS status && exit 0 || exit $?
}

case "$1" in
  start)
     shorewall6_start
     ;;
  stop)
     shorewall6_stop
     ;;
  refresh)
     shorewall6_refresh
  	  ;;
  force-reload|restart)
     shorewall6_restart
     ;;
  status)
     shorewall6_status
     ;;
  *)
     echo "Usage: /etc/init.d/shorewall6 {start|stop|refresh|restart|force-reload|status}"
     exit 1
esac

exit 0
