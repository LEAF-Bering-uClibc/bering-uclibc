# makefile for initrd

INITRD_DIR=.
INITRD_TARGET_DIR:=$(BT_BUILD_DIR)/initrd
ESCKEY:=$(shell echo "a\nb"|awk '/\\n/ {print "-e"}')
UCLIBC_LOADER_LINK:=$(notdir $(lastword $(wildcard $(BT_STAGING_DIR)/lib/ld*-uClibc.so.0)))
UCLIBC_LOADER:=$(notdir $(lastword $(wildcard $(BT_STAGING_DIR)/lib/ld*-uClibc-*.so)))
UCLIBC_VERSION:=$(shell echo $(UCLIBC_LOADER) | sed 's/^.*-//;s/\.so//')

source:

$(INITRD_DIR)/.build:
	mkdir -p $(INITRD_TARGET_DIR)
	mkdir -p $(INITRD_TARGET_DIR)/var/lib/lrpkg
	mkdir -p $(INITRD_TARGET_DIR)/boot/etc
	mkdir -p $(INITRD_TARGET_DIR)/sbin

	echo $(ESCKEY) "isofs\nvfat" > $(INITRD_TARGET_DIR)/boot/etc/modules

	echo "uClibc_version = $(UCLIBC_VERSION)" >  uClibc.inc
	echo "uClibc_loader  = $(UCLIBC_LOADER)"  >> uClibc.inc
	echo "uClibc_loader_link  = $(UCLIBC_LOADER_LINK)"  >> uClibc.inc
	echo '?include <uClibc.files>'            >> uClibc.inc

	touch $(INITRD_DIR)/.build

build: $(INITRD_DIR)/.build
	cp -aL README $(INITRD_TARGET_DIR)/boot/etc
	cp -aL root.linuxrc $(INITRD_TARGET_DIR)/var/lib/lrpkg
	cp -aL root.helper $(INITRD_TARGET_DIR)/var/lib/lrpkg
	cp -aL hotplug.sh $(INITRD_TARGET_DIR)/sbin
	cp -a $(INITRD_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	rm -rf $(INITRD_TARGET_DIR)
	rm -f uClibc.inc
	rm -f $(INITRD_DIR)/.build

srcclean: clean
	rm -f $(INITRD_DIR)/.source
