############################################
# makefile for nettle
###########################################

NETTLE_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(NETTLE_SOURCE) 2>/dev/null)
NETTLE_TARGET_DIR:=$(BT_BUILD_DIR)/nettle

$(NETTLE_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(NETTLE_SOURCE)
	touch $(NETTLE_DIR)/.source

source: $(NETTLE_DIR)/.source

$(NETTLE_DIR)/.configured: $(NETTLE_DIR)/.source
	(cd $(NETTLE_DIR); ./configure \
	--prefix=/ \
	--disable-documentation \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME))
	touch $(NETTLE_DIR)/.configured

$(NETTLE_DIR)/.build: $(NETTLE_DIR)/.configured
	mkdir -p $(NETTLE_TARGET_DIR)
	mkdir -p $(NETTLE_TARGET_DIR)/usr/lib
	mkdir -p $(NETTLE_TARGET_DIR)/usr/include/nettle
	
	
	make $(MAKEOPTS) -C $(NETTLE_DIR) DESTDIR=$(NETTLE_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS)" all
	cp -a $(NETTLE_DIR)/libhogweed.so $(NETTLE_TARGET_DIR)/usr/lib
	cp -a $(NETTLE_DIR)/libnettle.so $(NETTLE_TARGET_DIR)/usr/lib
	cp -a $(NETTLE_DIR)/*.h $(NETTLE_TARGET_DIR)/usr/include/nettle
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NETTLE_TARGET_DIR)/usr/lib/*
	cp -a $(NETTLE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(NETTLE_DIR)/.build

build: $(NETTLE_DIR)/.build

clean:
	make -C $(NETTLE_DIR) clean
	rm -rf $(NETTLE_TARGET_DIR)
	rm -rf $(NETTLE_DIR)/.build
	rm -rf $(NETTLE_DIR)/.configured

srcclean: clean
	rm -rf $(NETTLE_DIR)
