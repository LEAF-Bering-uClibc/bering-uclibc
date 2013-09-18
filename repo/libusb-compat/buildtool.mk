# makefile for libusb-compat

LIBUSBCOMPAT_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBUSBCOMPAT_SOURCE) 2>/dev/null )
LIBUSBCOMPAT_TARGET_DIR:=$(BT_BUILD_DIR)/libusb-compat

$(LIBUSBCOMPAT_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBUSBCOMPAT_SOURCE)
	touch $(LIBUSBCOMPAT_DIR)/.source

source: $(LIBUSBCOMPAT_DIR)/.source

$(LIBUSBCOMPAT_DIR)/.configured: $(LIBUSBCOMPAT_DIR)/.source
	(cd $(LIBUSBCOMPAT_DIR); \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-build-docs)
	touch $(LIBUSBCOMPAT_DIR)/.configured

$(LIBUSBCOMPAT_DIR)/.build: $(LIBUSBCOMPAT_DIR)/.configured
	mkdir -p $(LIBUSBCOMPAT_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBUSBCOMPAT_DIR)
	$(MAKE) DESTDIR=$(LIBUSBCOMPAT_TARGET_DIR) -C $(LIBUSBCOMPAT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBUSBCOMPAT_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBUSBCOMPAT_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBUSB_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	cp -a -f $(LIBUSBCOMPAT_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(LIBUSBCOMPAT_DIR)/.build

build: $(LIBUSBCOMPAT_DIR)/.build

clean:
	-$(MAKE) -C $(LIBUSBCOMPAT_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libusb-0.1*
	rm -f $(BT_STAGING_DIR)/usr/lib/libusb.so
	rm -f $(BT_STAGING_DIR)/usr/lib/libusb.la
	rm -f $(BT_STAGING_DIR)/usr/lib/libusb.a
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libusb.pc
	rm -f $(BT_STAGING_DIR)/usr/include/usb.h
	rm -f $(BT_STAGING_DIR)/usr/bin/libusb-config
	rm -rf $(LIBUSBCOMPAT_TARGET_DIR)
	rm -rf $(LIBUSBCOMPAT_DIR)/.build
	rm -rf $(LIBUSBCOMPAT_DIR)/.configured

srcclean: clean
	rm -rf $(LIBUSBCOMPAT_DIR)
