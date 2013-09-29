#############################################################
#
# buildtool makefile for nfs-utils
#
#############################################################


NFSUTILS_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(NFSUTILS_SOURCE) 2>/dev/null )
NFSUTILS_TARGET_DIR:=$(BT_BUILD_DIR)/nfs-utils

# Option settings for 'configure':
#   Disable tiprc to avoid build failure checking for clnt_tli_create()
#   Disable uuid to avoid the need for libblkid
#   Disable gss to avoid the need for libgssglue etc.
#   Disable nfsv4 to avoid the need for sqlite3
#   Disable nfsv41 to avoid the need for libdevmapper

CONFOPTS:= --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-tirpc \
	--disable-uuid \
	--disable-gss \
	--disable-nfsv4 \
	--disable-nfsv41	

$(NFSUTILS_DIR)/.source:
	bzcat $(NFSUTILS_SOURCE) | tar -xvf -
	# Patch support/include/sockaddr.h to avoid attempt to #include <libio.h>
	( cd $(NFSUTILS_DIR) ; perl -i -p -e 's,#include <libio.h>,,' support/include/sockaddr.h )
	touch $(NFSUTILS_DIR)/.source

source: $(NFSUTILS_DIR)/.source

# Need libwrap (TCP_WRAPPERS) for the "configure" step, so run configure
# as part of "build" rather than "source" so that dependency is resolved

$(NFSUTILS_DIR)/.configure: $(NFSUTILS_DIR)/.source
	( cd $(NFSUTILS_DIR) ; ./configure $(CONFOPTS) )
	touch $(NFSUTILS_DIR)/.configure

build: $(NFSUTILS_DIR)/.configure
	mkdir -p $(NFSUTILS_TARGET_DIR)
	mkdir -p $(NFSUTILS_TARGET_DIR)/etc/default
	mkdir -p $(NFSUTILS_TARGET_DIR)/etc/init.d
	$(MAKE) $(MAKEOPTS) -C $(NFSUTILS_DIR)/support
	$(MAKE) $(MAKEOPTS) -C $(NFSUTILS_DIR)/utils
	$(MAKE) -C $(NFSUTILS_DIR)/utils DESTDIR=$(NFSUTILS_TARGET_DIR) install

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/sbin/*
	cp -aL nfs-utils.default $(NFSUTILS_TARGET_DIR)/etc/default/nfs-utils
	cp -aL nfs-utils.exports $(NFSUTILS_TARGET_DIR)/etc/exports
	cp -aL nfs-utils.init $(NFSUTILS_TARGET_DIR)/etc/init.d/nfs-utils
	cp -aL idmapd.conf $(NFSUTILS_TARGET_DIR)/etc/
	-rm -rf $(NFSUTILS_TARGET_DIR)/usr/share
	cp -a $(NFSUTILS_TARGET_DIR)/* $(BT_STAGING_DIR)/

clean:
	rm -rf $(NFSUTILS_TARGET_DIR)
	$(MAKE) -C $(NFSUTILS_DIR) clean
	rm -f $(NFSUTILS_DIR)/.configure

srcclean: clean
	rm -rf $(NFSUTILS_DIR)
