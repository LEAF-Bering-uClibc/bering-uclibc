############################################
# makefile for libxml2
###########################################

LIBXML2_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBXML2_SOURCE) 2>/dev/null)
LIBXML2_TARGET_DIR:=$(BT_BUILD_DIR)/libxml2

$(LIBXML2_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBXML2_SOURCE)
	touch $(LIBXML2_DIR)/.source

source: $(LIBXML2_DIR)/.source

$(LIBXML2_DIR)/.configured: $(LIBXML2_DIR)/.source
	(cd $(LIBXML2_DIR); ./configure \
	--prefix=/ \
	--host=$(GNU_TARGET_NAME) \
	--without-python \
	--build=$(GNU_BUILD_NAME))
	touch $(LIBXML2_DIR)/.configured

$(LIBXML2_DIR)/.build: $(LIBXML2_DIR)/.configured
	mkdir -p $(LIBXML2_TARGET_DIR)
	mkdir -p $(LIBXML2_TARGET_DIR)/usr/bin
	mkdir -p $(LIBXML2_TARGET_DIR)/usr/lib

	make $(MAKEOPTS) -C $(LIBXML2_DIR) DESTDIR=$(LIBXML2_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS)" all
	cp -a $(LIBXML2_DIR)/.libs/libxml2* $(LIBXML2_TARGET_DIR)/usr/lib
	cp -a $(LIBXML2_DIR)/.libs/xmlcatalog $(LIBXML2_TARGET_DIR)/usr/bin
	cp -a $(LIBXML2_DIR)/.libs/xmllint $(LIBXML2_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBXML2_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBXML2_TARGET_DIR)/usr/lib/*
	cp -a $(LIBXML2_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBXML2_DIR)/.build

build: $(LIBXML2_DIR)/.build

clean:
	make -C $(LIBXML2_DIR) clean
	rm -rf $(LIBXML2_TARGET_DIR)
	rm -rf $(LIBXML2_DIR)/.build
	rm -rf $(LIBXML2_DIR)/.configured

srcclean: clean
	rm -rf $(LIBXML2_DIR)
