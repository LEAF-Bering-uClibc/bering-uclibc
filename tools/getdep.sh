#!/bin/sh

DEPFILE="$BT_STAGING_DIR/lib/modules/$BT_KERNEL_RELEASE/modules.dep"
MLIST=""

for i in $@; do
    i=$(echo $i | sed 's,/,\\/,g')
    ULIST=$(awk '/\/'"$i"'\.ko(\.gz)?:/ {split( $0, Name, ":"); print Name[1]; for (i=2; i<NF; i++){ print $i " "}; if (NF>1) print $NF}' $DEPFILE)
    #ULIST=$(grep "$i\.ko\(\.gz\)\?:" $DEPFILE | sed 's/\.ko\(\.gz\)\?:.*$//g')
    MLIST="$MLIST $ULIST"
done
echo $MLIST | sed 's,\s,\n,g' | sort | uniq
