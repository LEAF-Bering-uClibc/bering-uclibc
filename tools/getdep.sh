#!/bin/sh

DEPFILE="$BT_STAGING_DIR/lib/modules/$BT_KERNEL_RELEASE/modules.dep"
REQMOD=""

for i in $@; do
    ULIST=$(grep "$i\.ko\(\.gz\)\?:" $DEPFILE | sed 's/\.ko\(\.gz\)\?:.*$//g')
    MLIST="$MLIST $ULIST"
done

for i in $MLIST; do
    MODLIST=$(grep "$i\.ko\(\.gz\)\?:" $DEPFILE | sed 's/://')
    DMODLIST=""
    for j in $MODLIST; do
	if [ "$(echo $REQMOD|grep $j)" = "" ]; then
	    DMODLIST="$j $DMODLIST"
	fi
    done
    REQMOD="$REQMOD $DMODLIST"
done

echo $REQMOD