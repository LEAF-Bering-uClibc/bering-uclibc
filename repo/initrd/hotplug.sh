#!/bin/sh

[ "$ACTION" = add ] && [ "$MODALIAS" != "" ] && modprobe $MODALIAS
if [ "$ACTION" = remove ] && [ "$MODALIAS" != "" ]; then
	modprobe -r $MODALIAS
	# modprobe can remove actually needed modules, so we should
	# touch uevent for load all required modules for cold-plugged devices
	find /sys -type f -name 'uevent' | while read dev_event; do
		echo 'add' > $dev_event
	done
fi

/sbin/mdev $@
