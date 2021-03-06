#############################################################
# makefile for gettext
#############################################################

DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null)

TARGET_DIR:=$(BT_BUILD_DIR)/gettext
export CC=$(TARGET_CC)
PERLVER:=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)
export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER)

$(DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SOURCE)
	touch $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME) \
		--disable-static \
		--prefix=/usr);
	touch $(DIR)/.configured

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	$(MAKE) $(MAKEOPTS) -C $(DIR)/gettext-runtime/intl
	$(MAKE) DESTDIR=$(TARGET_DIR) \
		-C $(DIR)/gettext-runtime/intl install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(TARGET_DIR)/usr/lib/*.la
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libintl.*
	rm -f $(BT_STAGING_DIR)/usr/include/libintl.h
	$(MAKE) -C $(DIR) clean

srcclean: clean
	rm -rf $(DIR)

