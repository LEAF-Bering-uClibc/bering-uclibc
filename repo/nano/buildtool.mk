############################################
# makefile for nano
###########################################

NANO_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(NANO_SOURCE) 2>/dev/null)
NANO_TARGET_DIR:=$(BT_BUILD_DIR)/nano

$(NANO_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(NANO_SOURCE)
	touch $(NANO_DIR)/.source

source: $(NANO_DIR)/.source

$(NANO_DIR)/.configured: $(NANO_DIR)/.source
	(cd $(NANO_DIR) ; ./configure \
	--build=$(GNU_BUILD_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--disable-speller \
	--disable-nls \
	--disable-mouse \
	--disable-extra \
	--disable-color \
	--disable-operatingdir \
	--sysconfdir=/etc \
	--prefix=/usr)                                                                                  
	touch $(NANO_DIR)/.configured

$(NANO_DIR)/.build: $(NANO_DIR)/.configured
	mkdir -p $(NANO_TARGET_DIR)
	mkdir -p $(NANO_TARGET_DIR)/usr/bin
	mkdir -p $(NANO_TARGET_DIR)/etc
	make $(MAKEOPTS) -C $(NANO_DIR)
	cp -a $(NANO_DIR)/src/nano $(NANO_TARGET_DIR)/usr/bin
	cp -a $(NANO_DIR)/doc/nanorc.sample $(NANO_TARGET_DIR)/etc/nanorc
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NANO_TARGET_DIR)/usr/bin/*
	cp -a $(NANO_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(NANO_DIR)/.build

build: $(NANO_DIR)/.build

clean:
	make -C $(NANO_DIR) clean
	rm -rf $(NANO_TARGET_DIR)
	rm -rf $(NANO_DIR)/.build
	rm -rf $(NANO_DIR)/.configured

srcclean: clean
	rm -rf $(NANO_DIR)
