#!/bin/sh

. /etc/backup.conf

if [ -z "$STORAGE_MEDIA" ]; then
    exit 1;
fi

files=`ls $STORAGE_MEDIA`
fl=""
for i in $files; do 
    fl=$fl+$i
done;
in.tftpd -l -s $STORAGE_MEDIA
wget --post-data="$fl" $MIRROR/backup.cgi -O /tmp/bk.res 
if [ "`cat /tmp/bk.res`" -ne 0 ]; then
    echo `date`": Backup failed" >>/var/log/backup.log
else
    echo `date`": Backup successful" >>/var/log/backup.log
fi
kill `ps |grep "$STORAGE_MEDIA"|awk '{print $1}'`
rm /tmp/bk.res