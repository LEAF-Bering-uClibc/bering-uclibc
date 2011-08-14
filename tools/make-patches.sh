#! /bin/sh
# a script to make patching easier
# (c) 2003 Arne Bernin,
# based on kernel-patches from Erik Andersen:
#
# (c) 2002 Erik Andersen <andersen@codepoet.org>

# Set directories from arguments, or use defaults.
targetdir=${1-.}
patchdir=${2}
patchpattern=${3-*}

if [ ! -d "${targetdir}" ] ; then
    echo "Aborting.  '${targetdir}' is not a directory."
    exit 1
fi
if [ ! -d "${patchdir}" ] ; then
    echo "Aborting.  '${patchdir}' is not a directory."
    exit 1
fi
    
for i in ${patchdir}/${patchpattern} ; do 
    case "$i" in
	*.gz)
	type="gzip"; uncomp="gunzip -dc"; ;; 
	*.bz)
	type="bzip"; uncomp="bunzip -dc"; ;; 
	*.bz2)
	type="bzip2"; uncomp="bunzip2 -dc"; ;; 
	*.zip)
	type="zip"; uncomp="unzip -d"; ;; 
	*.Z)
	type="compress"; uncomp="uncompress -c"; ;; 
	*)
	type="plaintext"; uncomp="cat"; ;; 
    esac
    echo ""
    echo "Applying ${i} using ${type}: " 
    ${uncomp} ${i} | patch -p1 -E -d ${targetdir} 
    if [ $? != 0 ] ; then
        echo "Patch failed!  Please fix $i!"
	exit 1
    fi
done

# Check for rejects...
if [ "`find $targetdir/ '(' -name '*.rej' -o -name '.*.rej' ')' -print`" ] ; then
    echo "Aborting.  Reject files found."
    exit 1
fi

# Remove backup files
find $targetdir/ '(' -name '*.orig' -o -name '.*.orig' ')' -exec rm -f {} \;