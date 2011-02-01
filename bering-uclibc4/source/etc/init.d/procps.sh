#! /bin/sh
# /etc/init.d/procps: Set kernel variables from /etc/sysctl.conf
#
RCDLINKS="S,S30"

[ -x /sbin/sysctl ] || exit 0

if [ ! -r /etc/sysctl.conf ]
then
   exit 0
fi

echo "Setting kernel variables ..."
eval "/sbin/sysctl -p"
echo "done."
