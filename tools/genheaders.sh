#!/bin/sh

BTROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null || echo '.')

if [ ! -f "$BTROOTDIR/make/toolchain/$1.mk" ]; then
	echo "Toolchain $1 doesn't exists."
	echo "Usage: $0 [toolchain-name]"
	exit
fi

BTROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null || echo '.')
# Remove 'linux' target for more universal usage
$BTROOTDIR/buildtool.pl -t $1 headers || exit
tar cjf $BTROOTDIR/headers/common.tar.bz2 -C $BTROOTDIR/headers/$1/include . --exclude '..install.cmd' --exclude '.install' --exclude 'asm'
tar cjf $BTROOTDIR/headers/$1.tar.bz2 -C $BTROOTDIR/headers/$1/include asm --exclude '..install.cmd' --exclude '.install'
