#!/bin/sh

[ "$ACTION" = add ] && [ "$MODALIAS" != "" ] && modprobe $MODALIAS
[ "$ACTION" = remove ] && [ "$MODALIAS" != "" ] && modprobe -r $MODALIAS

/sbin/mdev $@
