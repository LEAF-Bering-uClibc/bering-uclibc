# makefile for libusb

LIBUSB_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBUSB_SOURCE) 2>/dev/null )
LIBUSB_TARGET_DIR:=$(BT_BUILD_DIR)/libusb

$(LIBUSB_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBUSB_SOURCE)
	zcat $(BT_TOOLS_DIR)/config.sub.gz >$(LIBUSB_DIR)/config.sub
	touch $(LIBUSB_DIR)/.source

source: $(LIBUSB_DIR)/.source

$(LIBUSB_DIR)/.configured: $(LIBUSB_DIR)/.source
	(cd $(LIBUSB_DIR); \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-udev \
	--disable-build-docs)
	touch $(LIBUSB_DIR)/.configured

$(LIBUSB_DIR)/.build: $(LIBUSB_DIR)/.configured
	mkdir -p $(LIBUSB_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBUSB_DIR)
	$(MAKE) DESTDIR=$(LIBUSB_TARGET_DIR) -C $(LIBUSB_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBUSB_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBUSB_TARGET_DIR)/usr/lib/*.la
	cp -a -f $(LIBUSB_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(LIBUSB_DIR)/.build

build: $(LIBUSB_DIR)/.build

clean:
	-$(MAKE) -C $(LIBUSB_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libusb-1*
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libusb.pc
	rm -rf $(LIBUSB1_TARGET_DIR)
	rm -rf $(LIBUSB1_DIR)/.build
	rm -rf $(LIBUSB1_DIR)/.configured

srcclean: clean
	rm -rf $(LIBUSB_DIR)
