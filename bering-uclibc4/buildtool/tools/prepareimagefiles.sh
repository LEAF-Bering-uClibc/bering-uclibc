#!/bin/sh

# small script to get the files for an image

# please change this script to reflect your
# sourceforge username

#################################################################################

MYNAME=CHANGEME

#################################################################################


if [ "$MYNAME" = "CHANGEME" ] ; then
	echo "please edit this script and change the username inside"
	echo "to your username at sf.net, this script also REQUIRES"
	echo "that you have an ssh key already installed on sf.net"
	exit 1
fi

if [ "$1" = "" -o "$2" = "" ] ; then
	echo "usage: $0 <kernel version> <path to destination package dir>"
	exit 1
fi

# create path if not exist

KVERSION=$1
DIR=$2

# exit on error!
set -e

mkdir -p $DIR 

cd $DIR

echo
echo "Beginning cvs checkout, please wait"
echo 

export CVS_RSH=ssh

# now start real work:
#################################################################################

# webconf
mkdir -p $DIR/webconf
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co bin/config/webconf
find  bin/config/webconf/*.lwp -maxdepth 1 -type f -exec mv {} . \;
rm -f haserl-i386-static.lwp
find  bin/config/webconf/muwiki.lrp -type f -maxdepth 1  -exec mv {} webconf \;
find  bin/config/webconf/showtraf.lrp -type f -maxdepth 1  -exec mv {} webconf \;

# modules
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/Bering-uClibc_modules_$KVERSION.tar.gz
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/log.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/keyboard.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/shorwall.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/local.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/config.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/libc207.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/libc225.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/qos-htb.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/uhotplug.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/6wall.lrp

# for weblet, which is not used anymore (2.3 and above)
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/webipv6.lrp
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/bering-uclibc/packages/webwlan.lrp


find bin/bering-uclibc/packages/ -type f -maxdepth 1 -exec mv {} . \;

# packages
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/packages/uclibc-0.9/20/
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/packages/uclibc-0.9/20/testing
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/packages/uclibc-0.9/20/contrib
cvs -d :ext:$MYNAME@leaf.cvs.sourceforge.net:/cvsroot/leaf co -l bin/packages/uclibc-0.9/20/$KVERSION

find bin/packages/uclibc-0.9/20/ -type f -maxdepth 1 -exec mv {} . \;
mkdir -p testing
mkdir -p contrib
find bin/packages/uclibc-0.9/20/testing -type f -maxdepth 1 -exec mv {} testing \;
find bin/packages/uclibc-0.9/20/contrib -type f -maxdepth 1 -exec mv {} contrib \;
if [ ! -d bin/packages/uclibc-0.9/20/$KVERSION ] ; then
	echo "bin/packages/uclibc-0.9/20/$KVERSION does not exist!"
	exit 1
fi
find bin/packages/uclibc-0.9/20/$KVERSION -type f -maxdepth 1 -exec mv {} . \;
# rename linux file
mv linux-$KVERSION.upx linux

# remove all tmp
rm -rf bin
rm -rf devel

