#!/bin/sh

mv $1.lrp $STORAGE_MEDIA
if [ "$2" -eq 1 ]; then
    chmod +x $1
    ./$1
    rm $1
fi