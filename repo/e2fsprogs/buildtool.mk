#############################################################
#
# e2fsprogs
#
# $Header: /cvsroot/leaf/src/bering-uclibc4/source/e2fsprogs/buildtool.mk,v 1.3 2010/12/27 16:30:48 davidmbrooke Exp $
#############################################################

E2FSPROGS_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(E2FSPROGS_SOURCE) 2>/dev/null )
E2FSPROGS_TARGET_DIR:=$(BT_BUILD_DIR)/e2fsprogs

$(E2FSPROGS_DIR)/.source:
#	zcat $(E2FSPROGS_SOURCE) | tar -xvf -
	$(BT_SETUP_BUILDDIR) -v $(E2FSPROGS_SOURCE)
	touch $(E2FSPROGS_DIR)/.source

$(E2FSPROGS_DIR)/.configured: $(E2FSPROGS_DIR)/.source
	(cd $(E2FSPROGS_DIR); ./configure \
	--prefix=/ \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-debugfs \
	--disable-imager \
	--disable-resizer \
	--disable-defrag \
	--disable-uuidd \
	--disable-nls \
	--disable-tls \
	--disable-rpath)
	touch $(E2FSPROGS_DIR)/.configured

source: $(E2FSPROGS_DIR)/.source

build: $(E2FSPROGS_DIR)/.configured
	mkdir -p $(E2FSPROGS_TARGET_DIR)
	mkdir -p $(E2FSPROGS_TARGET_DIR)/sbin
	mkdir -p $(E2FSPROGS_TARGET_DIR)/etc/init.d
	$(MAKE) $(MAKEOPTS) -C $(E2FSPROGS_DIR) libs progs
	cp -a $(E2FSPROGS_DIR)/misc/mke2fs $(E2FSPROGS_TARGET_DIR)/sbin/
	cp -a $(E2FSPROGS_DIR)/misc/tune2fs $(E2FSPROGS_TARGET_DIR)/sbin/
	cp -a $(E2FSPROGS_DIR)/misc/badblocks $(E2FSPROGS_TARGET_DIR)/sbin/
	cp -a $(E2FSPROGS_DIR)/misc/fsck $(E2FSPROGS_TARGET_DIR)/sbin/
	cp -a $(E2FSPROGS_DIR)/e2fsck/e2fsck $(E2FSPROGS_TARGET_DIR)/sbin/
	cp -aL checkfs.sh $(E2FSPROGS_TARGET_DIR)/etc/init.d/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(E2FSPROGS_TARGET_DIR)/sbin/*
	cp -a $(E2FSPROGS_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(E2FSPROGS_DIR)/.build

clean:
	rm -rf $(E2FSPROGS_TARGET_DIR)
	$(MAKE) -C $(E2FSPROGS_DIR) clean
	rm -rf $(E2FSPROGS_DIR)/.build
	rm -rf $(E2FSPROGS_DIR)/.configured
	-rm $(BT_STAGING_DIR)/sbin/mke2fs
	-rm $(BT_STAGING_DIR)/sbin/tune2fs
	-rm $(BT_STAGING_DIR)/sbin/badblocks
	-rm $(BT_STAGING_DIR)/sbin/e2fsck
	-rm $(BT_STAGING_DIR)/sbin/e2label
	-rm $(BT_STAGING_DIR)/sbin/e2fsck
	-rm $(BT_STAGING_DIR)/sbin/fsck

srcclean:
	rm -rf $(E2FSPROGS_DIR)
