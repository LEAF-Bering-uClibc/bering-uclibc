#
# bootmisc.sh	Miscellaneous things to be done during bootup.
#
RCDLINKS="S,S55"

. /etc/default/rcS
#
# Put a nologin file in /etc to prevent people from logging in before
# system startup is complete.
#
if [ "$DELAYLOGIN" = yes ]
then
  echo "System bootup in progress - please wait" >/etc/nologin
fi

#
# Create /var/run/utmp so that we can login.
#
: > /var/run/utmp

#
# Set pseudo-terminal access permissions.
#
#chmod 666 /dev/tty[p-za-e][0-9a-f]
#chown root:tty /dev/tty[p-za-e][0-9a-f]

#
# Save kernel messages in /var/log/dmesg
#
dmesg -s 524288 > /var/log/dmesg
#chgrp wheel /var/log/dmesg

#
# Update /etc/motd.
#
if [ "$EDITMOTD" != no ]
then
	kern=$(uname -srv)
	initrd=$(cat /var/lib/lrpkg/initrd.version)
	host=$(cat /proc/sys/kernel/hostname)
	echo -e "LEAF Bering-uClibc $initrd at $(cat /proc/sys/kernel/hostname)\n$kern">/etc/motd

	echo "$kern" >/etc/issue
	echo "LEAF Bering-uClibc $initrd \n \l" >>/etc/issue
	echo -e "$kern\nLEAF Bering-uClibc $initrd %h" >/etc/issue.net
fi
