#############################################################
#
# buildtool makefile for nfs-utils
#
#############################################################

include $(MASTERMAKEFILE)

NFSUTILS_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(NFSUTILS_SOURCE) 2>/dev/null )
ifeq ($(NFSUTILS_DIR),)
NFSUTILS_DIR:=$(shell cat DIRNAME)
endif
NFSUTILS_TARGET_DIR:=$(BT_BUILD_DIR)/nfs-utils

# Option settings for 'configure':
#   Disable tiprc to avoid build failure checking for clnt_tli_create()
#   Disable uuid to avoid the need for libblkid
#   Disable gss to avoid the need for libgssglue etc.
CONFOPTS:= --build=$(GNU_TARGET_NAME) --host=$(GNU_HOST_NAME) \
	--disable-tirpc --disable-uuid --disable-gss

$(NFSUTILS_DIR)/.source:
	bzcat $(NFSUTILS_SOURCE) | tar -xvf -
	echo $(NFSUTILS_DIR) > DIRNAME
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
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(NFSUTILS_DIR)
	$(MAKE) -C $(NFSUTILS_DIR) DESTDIR=$(NFSUTILS_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/exportfs
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/exportfs $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/nfsstat
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/nfsstat $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.mountd
	cp $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.mountd $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.nfsd
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.nfsd $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.statd
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.statd $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.idmapd
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/rpc.idmapd $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/showmount
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/showmount $(BT_STAGING_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NFSUTILS_TARGET_DIR)/usr/sbin/sm-notify
	cp -f $(NFSUTILS_TARGET_DIR)/usr/sbin/sm-notify $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/default/
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	cp -aL nfs-utils.default $(BT_STAGING_DIR)/etc/default/nfs-utils
	cp -aL nfs-utils.exports $(BT_STAGING_DIR)/etc/exports
	cp -aL nfs-utils.init $(BT_STAGING_DIR)/etc/init.d/nfs-utils
	cp -aL idmapd.conf $(BT_STAGING_DIR)/etc/

clean:
	rm -rf $(NFSUTILS_TARGET_DIR)
	$(MAKE) -C $(NFSUTILS_DIR) clean
	rm -f $(NFSUTILS_DIR)/.configure

srcclean: clean
	rm -rf $(NFSUTILS_DIR) 
	-rm DIRNAME

