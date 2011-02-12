# makefile for libusb
include $(MASTERMAKEFILE)

LIBUSB_DIR:=libusb-0.1.12
LIBUSB_TARGET_DIR:=$(BT_BUILD_DIR)/libusb

$(LIBUSB_DIR)/.source:
	zcat $(LIBUSB_SOURCE) | tar -xvf -
	touch $(LIBUSB_DIR)/.source

source: $(LIBUSB_DIR)/.source
                        
$(LIBUSB_DIR)/.configured: $(LIBUSB_DIR)/.source
	(cd $(LIBUSB_DIR) ; CFLAGS="$(BT_COPT_FLAGS)" CXXFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) CXX=$(BT_STAGING_DIR)/usr/bin/g++ LD=$(TARGET_LD) \
	./configure --prefix=$(LIBUSB_TARGET_DIR)/usr --disable-build-docs)
	touch $(LIBUSB_DIR)/.configured
                                                                 
$(LIBUSB_DIR)/.build: $(LIBUSB_DIR)/.configured
	mkdir -p $(LIBUSB_TARGET_DIR)
	$(MAKE) -C $(LIBUSB_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBUSB_TARGET_DIR)/usr/lib/*.so*
	perl -i -p -e 's,/.*/usr/lib,$(BT_STAGING_DIR)/usr/lib,g' \
		$(LIBUSB_TARGET_DIR)/usr/lib/*.la
	cp -a -f $(LIBUSB_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a -f $(LIBUSB_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include	
	cp -a -f $(LIBUSB_TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin
	touch $(LIBUSB_DIR)/.build

build: $(LIBUSB_DIR)/.build
                                                                                         
clean:
	-$(MAKE) -C $(LIBUSB_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libusb.*
	rm -f $(BT_STAGING_DIR)/usr/lib/libusbpp.*
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libusb.pc
	rm -f $(BT_STAGING_DIR)/usr/include/usb.h
	rm -f $(BT_STAGING_DIR)/usr/include/usbpp.h
	rm -f $(BT_STAGING_DIR)/usr/bin/libusb-config
	rm -rf $(LIBUSB_TARGET_DIR)
	rm -rf $(LIBUSB_DIR)/.build
	rm -rf $(LIBUSB_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(LIBUSB_DIR) 
