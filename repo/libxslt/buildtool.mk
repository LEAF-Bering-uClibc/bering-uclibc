############################################
# makefile for libxslt
###########################################

LIBXSLT_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBXSLT_SOURCE) 2>/dev/null)
LIBXSLT_TARGET_DIR:=$(BT_BUILD_DIR)/libxslt

#export LDFLAGS += $(EXTCCLDFLAGS)

$(LIBXSLT_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBXSLT_SOURCE)
	touch $(LIBXSLT_DIR)/.source

source: $(LIBXSLT_DIR)/.source

$(LIBXSLT_DIR)/.configured: $(LIBXSLT_DIR)/.source
	(cd $(LIBXSLT_DIR); ./configure \
	--prefix=/ \
	--host=$(GNU_TARGET_NAME) \
	--with-libxml-prefix=$(BT_STAGING_DIR)/usr/ \
	--without-python \
	--without-crypto \
	--without-debug \
	--disable-static \
	--build=$(GNU_BUILD_NAME))
	touch $(LIBXSLT_DIR)/.configured

$(LIBXSLT_DIR)/.build: $(LIBXSLT_DIR)/.configured
	mkdir -p $(LIBXSLT_TARGET_DIR)
	mkdir -p $(LIBXSLT_TARGET_DIR)/usr/bin
	mkdir -p $(LIBXSLT_TARGET_DIR)/usr/lib

	make $(MAKEOPTS) -C $(LIBXSLT_DIR) DESTDIR=$(LIBXSLT_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS)" all
	cp -a $(LIBXSLT_DIR)/libexslt/.libs/libexslt.s* $(LIBXSLT_TARGET_DIR)/usr/lib
	cp -a $(LIBXSLT_DIR)/libxslt/.libs/libxslt.s* $(LIBXSLT_TARGET_DIR)/usr/lib
	cp -a $(LIBXSLT_DIR)/xslt-config $(LIBXSLT_TARGET_DIR)/usr/bin
	cp -a $(LIBXSLT_DIR)/xsltproc/xsltproc $(LIBXSLT_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBXSLT_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBXSLT_TARGET_DIR)/usr/lib/*
	cp -a $(LIBXSLT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBXSLT_DIR)/.build

build: $(LIBXSLT_DIR)/.build

clean:
	make -C $(LIBXSLT_DIR) clean
	rm -rf $(LIBXSLT_TARGET_DIR)
	rm -rf $(LIBXSLT_DIR)/.build
	rm -rf $(LIBXSLT_DIR)/.configured

srcclean: clean
	rm -rf $(LIBXSLT_DIR)
