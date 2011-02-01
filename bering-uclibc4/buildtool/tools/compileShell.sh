# $Id: compileShell.sh,v 1.1.1.1 2010/04/26 09:03:15 nitr0man Exp $
# just a small hack to set up some environment vars when
# compiling things "by hand"

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
MYPATH2=$(echo $MYPATH2 | sed -e 's/\/$//')
export BT_BUILDROOT=$MYPATH2
export MASTERINCLUDEFILE=$MYPATH2/make/MasterInclude.mk
export PATH=$MYPATH2/staging/usr/bin:$PATH

echo 
echo "This starts a new shell, you can leave this one with: exit" 
echo 
# exec shell
exec /bin/bash --init-file $MYPATH1/compileShellInit

