#! /bin/sh
#set -x
# script to create the bering-uclibc iso image
# $Id: geniso.sh,v 1.8 2010/11/11 22:32:24 nitr0man Exp $
# (C) 2005 Arne Bernin
# this file is released under the GNU Public Licence (GPL) 
# Version 2 or later

#######################################################################################################################################################
# adjust to your needs:
# Note: you can use pathnames in here (relative is the best of course, set the package path according if
# you call this script... If the path contains a : the string after the : will be used as target filename,
# if you have a file initrd_ide_cd.lrp and want to name it initrd.lrp on the floppy image, use:
# initrd_ide_cd.lrp:initrd.lrp


#######################################################################################################################################################
export LANG=C

print_usage() {
	cat <<EOF
usage: $0 <release version> <kernel arch> [kernel version]
$0 creates a ready to use iso Image.
<release version> is the bering-uclibc release, e.g. 2.3beta5.
<kernel arch> is the kernel architecture you are using (i.e. i486, i686, geode).
[kernel version] is the kernel version you are using, if it is blank - latest
built version from source/linux is used.
EOF

}

#### look at how we are called:
if [ "$1" = "" ] ; then
	print_usage
	exit 1
fi


TYPE=$(echo $1 | tr [:lower:] [:upper:])

#################
DATE=$(date "+%B %Y")
VERSION=$1
KARCH=$2
KVERSION=$3

#### get clear path(s):
# check if we were called with an absolute path or a relative one
echo $0 | grep -q '^/.*'
if [ $? -eq 0 ]  ; then 
MYPATH=$0
else
MYPATH=$(pwd)/$0
fi

export LANG=C

MYPATH1=$(dirname $MYPATH)
# cut of /./, and . at end and tools
MYPATH2=$(echo $MYPATH1 | sed -e 's/\/.\//\//g' | sed -e 's/\/\.$//' | sed -e 's/tools$//')
# strip ending : /
BTROOT=$(echo $MYPATH2 | sed -e 's/\/$//')
IMGPATH=${BTROOT}/image
STGDIR=${BTROOT}/staging
SRCDIR=${BTROOT}/source
TMPDIR=$(mktemp -d -p /tmp CREATE_XXXXXX)
IMG=${TMPDIR}/floppy.img
TOOLSDIR=${BTROOT}/tools
FDDIR=${TOOLSDIR}/image/iso
FDBASEDIR=${TOOLSDIR}/image
if [ -f "$FDDIR/filelist" ] ; then
	. $FDDIR/filelist
else
	echo "$FDDIR/filelist is missing"
	exit 1
fi

echo "FILELIST=$FILELIST"

# set pkgdir
PKGDIR=$BTROOT/package

if [ "$KVERSION" = "" ] ; then
	# find latest version
	KVERSION=`cat $SRCDIR/linux/linux-$KARCH/.config | awk '/version:/ {print $5}'`
fi

# check directory
retval=0

echo "copying files to $TMPDIR"
# copy base files
find $PKGDIR -maxdepth 1 -type f -exec cp {} $TMPDIR \;
#mkdir -p $TMPDIR/contrib
#mkdir -p $TMPDIR/testing
#find $PKGDIR/testing -maxdepth 1 -type f -exec cp {} $TMPDIR/testing \;
#find $PKGDIR/contrib -maxdepth 1 -type f -exec cp {} $TMPDIR/contrib \;
#find $PKGDIR/$KVERSION -maxdepth 1 -type f -exec cp {} $TMPDIR \;
cp -R $PKGDIR/* $TMPDIR

echo "creating image"

set -e
# now create the image dir
mkdir -p $IMGPATH

# copy disk + unpack
echo $TMPDIR
mkdir -p $TMPDIR/isolinux
cp $STGDIR/usr/bin/isolinux.bin $TMPDIR/isolinux
retval=$?

set +e
# copy all files
#filelist=$(eval echo "\$FILELIST$TYPE")
for name in ${FILELIST} ; do
	echo $name | grep -q ":"
	if [ $? -eq 0 ] ; then
		src=$(echo $name | cut -d ':' -f 1)
		dst=$(echo $name | cut -d ':' -f 2)
	else
		src=$name
		dst=""
	fi
	echo copying $src to temp dir
	tretval=0
	cp ${PKGDIR}/`echo $src|sed "s,\(moddb\|initrd\|linux\)\(.*\),\1-$KARCH\2,"` $TMPDIR/$dst/$src
	tretval=$?
	if [ $tretval -ne 0 ] ; then
		retval=1
	fi
done

set -e

cp $FDDIR/leaf.cfg $TMPDIR
cp $STGDIR/boot/linux-$KARCH $TMPDIR/linux
cp $FDDIR/isolinux.cfg $TMPDIR/isolinux
cp $FDDIR/isolinux.ser $TMPDIR/isolinux
cp $FDDIR/configdb.ser $TMPDIR


#
sed -e "s/{DATE}/$DATE/g" -e "s/{VERSION}/$VERSION/g" $FDBASEDIR/syslinux.dpy > $TMPDIR/isolinux/isolinux.dpy
sed -e "s/{DATE}/$DATE/g" -e "s/{VERSION}/$VERSION/g" $FDBASEDIR/readme > $TMPDIR/readme

set +e

if [ $retval -ne 0 ] ; then
	echo "There have been errors while creating temporary directory!"
else
		set -e
#		(cd $TMPDIR/lib/modules ; tar xvzf ../../Bering-uClibc_modules_$KVERSION.tar.gz ; rm ../../Bering-uClibc_modules_$KVERSION.tar.gz )
#		rm $TMPDIR/lib/modules/$KVERSION/build
		(cd $STGDIR/lib/modules/$KVERSION-$KARCH; tar -czf $TMPDIR/modules.tgz *  --exclude=build --exclude=source)
		IMGNAME=$IMGPATH/Bering-uClibc_$VERSION'.'iso
		(cd $TMPDIR ; mkisofs -o $IMGNAME -v -b isolinux/isolinux.bin  -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -l -R -r .)

		set +e
	echo "image moved to $IMGNAME"
fi

rm -rf $TMPDIR
exit $retval
