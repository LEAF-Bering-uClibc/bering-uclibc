#############################################################
#
# util-linux (+loop-AES)
#
#############################################################

UTIL_LINUX_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(UTIL_LINUX_NG_SOURCE) 2>/dev/null )

UTIL_LINUX_TARGET_DIR:=$(BT_BUILD_DIR)/util-linux-ng
OPT="-pipe -fomit-frame-pointer $(BT_COPT_FLAGS)"
export $OPT

LOOPAES_DIR:=loop-AES-v3.1d

$(UTIL_LINUX_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(UTIL_LINUX_NG_SOURCE) 
	touch $(UTIL_LINUX_DIR)/.source

$(UTIL_LINUX_DIR)/.configured: $(UTIL_LINUX_DIR)/.source
	(cd $(UTIL_LINUX_DIR) ; ./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME) \
		--disable-nls --without-ncurses);
	touch $(UTIL_LINUX_DIR)/.configured

$(UTIL_LINUX_DIR)/.build: $(UTIL_LINUX_DIR)/.configured
	mkdir -p $(UTIL_LINUX_TARGET_DIR)/sbin
	mkdir -p $(UTIL_LINUX_TARGET_DIR)/lib
	mkdir -p $(UTIL_LINUX_TARGET_DIR)/usr/include/uuid

	$(MAKE) $(MAKEOPTS) -C $(UTIL_LINUX_DIR)/fdisk fdisk
	$(MAKE) $(MAKEOPTS) -C $(UTIL_LINUX_DIR)/mount losetup
	$(MAKE) $(MAKEOPTS) -C $(UTIL_LINUX_DIR)/misc-utils blkid findfs
	cp -a $(UTIL_LINUX_DIR)/fdisk/.libs/fdisk $(UTIL_LINUX_TARGET_DIR)/sbin/
	cp -a $(UTIL_LINUX_DIR)/mount/losetup $(UTIL_LINUX_TARGET_DIR)/sbin/
	cp -a $(UTIL_LINUX_DIR)/misc-utils/.libs/findfs $(UTIL_LINUX_TARGET_DIR)/sbin/
	cp -a $(UTIL_LINUX_DIR)/misc-utils/.libs/blkid $(UTIL_LINUX_TARGET_DIR)/sbin/
	cp -a $(UTIL_LINUX_DIR)/shlibs/blkid/src/.libs/libblkid.* $(UTIL_LINUX_TARGET_DIR)/lib/
	rm -f $(UTIL_LINUX_TARGET_DIR)/lib/libblkid.la
	cp -a $(UTIL_LINUX_DIR)/shlibs/blkid/src/libblkid.la $(UTIL_LINUX_TARGET_DIR)/lib/
	cp -a $(UTIL_LINUX_DIR)/shlibs/uuid/src/.libs/libuuid.* $(UTIL_LINUX_TARGET_DIR)/lib/
	rm -f $(UTIL_LINUX_TARGET_DIR)/lib/libuuid.la
	cp -a $(UTIL_LINUX_DIR)/shlibs/uuid/src/libuuid.la $(UTIL_LINUX_TARGET_DIR)/lib/
	cp -a $(UTIL_LINUX_DIR)/shlibs/uuid/src/uuid.h $(UTIL_LINUX_TARGET_DIR)/usr/include/uuid/
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/lib\'," $(UTIL_LINUX_TARGET_DIR)/lib/*.la
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(UTIL_LINUX_TARGET_DIR)/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(UTIL_LINUX_TARGET_DIR)/lib/*
	cp -a $(UTIL_LINUX_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(UTIL_LINUX_DIR)/.build

source: $(UTIL_LINUX_DIR)/.source

build: $(UTIL_LINUX_DIR)/.build

clean:
	-rm $(UTIL_LINUX_DIR)/.build
	-rm $(LOOPAES_DIR)/.build
	rm -rf $(UTIL_LINUX_TARGET_DIR)
	$(MAKE) -C $(UTIL_LINUX_DIR) clean

srcclean:
	rm -rf $(UTIL_LINUX_TARGET_DIR)
	rm -rf $(UTIL_LINUX_DIR)
