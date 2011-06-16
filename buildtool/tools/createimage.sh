#! /bin/sh
#set -x
# script to create the bering-uclibc floppy image
# $Id: createimage.sh,v 1.1.1.1 2010/04/26 09:03:16 nitr0man Exp $
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
usage: $0 <fd|iso> <cvs-bin path> <release version> <kernel version>
$0 creates a ready to use Floppy (1680k) or iso Image.
Choose fd for floppy image, iso for iso. <cvs bin path>
is the path to your checked out bin directory from cvs 
(use prepareimagefiles.sh for getting them out of cvs).
<release version> is the bering-uclibc release, e.g. 2.3beta5.
kernel version is the kernel version you are using.
EOF

}

#### look at how we are called:
if [ "$1" = "" -o "$2" = "" -o "$3" = "" -o "$4" = "" ] ; then
	print_usage
	exit 1
fi
if [ "$1" != "fd" -a "$1" != "iso" ] ; then
	print_usage
	exit 1
fi


TYPE=$(echo $1 | tr [:lower:] [:upper:])

#################
DATE=$(date "+%B %Y")
VERSION=$3

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
TMPDIR=$(mktemp -d -p /tmp CREATE_XXXXXX)
IMG=${TMPDIR}/floppy.img
TOOLSDIR=${BTROOT}/tools
FDDIR=${TOOLSDIR}/image/$1
FDBASEDIR=${TOOLSDIR}/image
if [ -f "$FDDIR/filelist" ] ; then
	. $FDDIR/filelist
else
	echo "$FDDIR/filelist is missing"
	exit 1
fi

echo "FILELIST=$FILELIST"

# set pkgdir
PKGDIR=$2

#if [ "$4" = "" ] ; then
#	# find latest version
#	
#
#fi
KVERSION=$4
# check directory
retval=0

# export mtoolsrc so it will be find:
export MTOOLSRC=${TOOLSDIR}/mtoolsrc 
# create mtoolsrc
echo drive a: file=\"$IMG\" exclusive > $MTOOLSRC
echo MTOOLS_NO_VFAT=1 >> $MTOOLSRC


echo "copying files to $TMPDIR"
# copy base files
find $PKGDIR -maxdepth 1 -type f -exec cp {} $TMPDIR \;
mkdir -p $TMPDIR/contrib
mkdir -p $TMPDIR/testing
find $PKGDIR/testing -maxdepth 1 -type f -exec cp {} $TMPDIR/testing \;
find $PKGDIR/contrib -maxdepth 1 -type f -exec cp {} $TMPDIR/contrib \;
find $PKGDIR/$KVERSION -maxdepth 1 -type f -exec cp {} $TMPDIR \;

echo "creating image"

set -e
# now create the image dir
mkdir -p $IMGPATH

# copy disk + unpack
echo $IMG
zcat $FDDIR/img*.bin.gz > $IMG

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
	echo copying $src to diskimage
	tretval=0
	#if [ "$dst" != "" ] ; then
			mcopy ${PKGDIR}/$src a:$dst
			tretval=$?
	#fi
	if [ $tretval -ne 0 ] ; then
		retval=1
	fi
done

set -e
# now copy rest files
mcopy -o $FDDIR/leaf.cfg a:leaf.cfg
cp $FDDIR/leaf.cfg $TMPDIR
mcopy -o $FDDIR/syslinux.cfg a:syslinux.cfg
cp $FDDIR/syslinux.cfg $TMPDIR
mcopy -o $FDDIR/syslinux.ser a:syslinux.ser
cp $FDDIR/syslinux.ser $TMPDIR
mcopy -o $FDDIR/configdb.ser a:configdb.ser
cp $FDDIR/configdb.ser $TMPDIR


#
sed -e "s/{DATE}/$DATE/g" -e "s/{VERSION}/$VERSION/g" $FDBASEDIR/syslinux.dpy > $TMPDIR/syslinux.dpy
sed -e "s/{DATE}/$DATE/g" -e "s/{VERSION}/$VERSION/g" $FDBASEDIR/readme > $TMPDIR/readme
mcopy -o $TMPDIR/syslinux.dpy a:syslinux.dpy
mcopy -o $TMPDIR/readme a:readme


mdir a:
set +e

if [ $retval -ne 0 ] ; then
	echo "There have been errors while creating the floppy image!"
else
	echo "floppy image created without error"
	if [ "$TYPE" = "ISO" ] ; then
		set -e
		mv $IMG ${TMPDIR}/bootdisk.ima
		cp -R $PKGDIR/* $TMPDIR
#		mkdir -p $TMPDIR/lib/modules
#		(cd $TMPDIR/lib/modules ; tar xvzf ../../Bering-uClibc_modules_$KVERSION.tar.gz ; rm ../../Bering-uClibc_modules_$KVERSION.tar.gz )
#		rm $TMPDIR/lib/modules/$KVERSION/build
		(cd $TMPDIR; ln -s Bering-uClibc_modules_$KVERSION.tar.gz modules.tgz )
		IMGNAME=$IMGPATH/Bering-uClibc_$VERSION'_'iso_bering-uclibc-iso.bin
#		(cd $TMPDIR ; mkisofs -v -b bootdisk.ima  -c boot.catalog -r -f -J -o $IMGNAME -m moddb.lrp .)
		(cd $TMPDIR ; mkisofs -v -b bootdisk.ima  -c boot.catalog -r -f -J -o $IMGNAME .)

		set +e
	else 
		set -e
		IMGNAME=$IMGPATH/Bering-uClibc_$VERSION'_'img_bering-uclibc-1680.bin

		mv $IMG $IMGNAME
		set +e

	fi
	echo "$TYPE image moved to $IMGNAME"

fi

rm -rf $TMPDIR
exit $retval
