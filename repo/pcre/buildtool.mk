######################################
#
# buildtool make file for pcre
#
######################################

PCRE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(PCRE_SOURCE) 2>/dev/null )
PCRE_TARGET_DIR:=$(BT_BUILD_DIR)/pcre

CONFFLAGS:= --prefix=/usr --disable-cpp

$(PCRE_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(PCRE_SOURCE)
	touch $(PCRE_DIR)/.source

source: $(PCRE_DIR)/.source

$(PCRE_DIR)/.configured: $(PCRE_DIR)/.source
	(cd $(PCRE_DIR) ; \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-static \
	--prefix=/usr )
	touch $(PCRE_DIR)/.configured

$(PCRE_DIR)/.build: $(PCRE_DIR)/.configured
	mkdir -p $(PCRE_TARGET_DIR)
	make $(MAKEOPTS) -C $(PCRE_DIR)
	make -C $(PCRE_DIR) DESTDIR=$(PCRE_TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PCRE_TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PCRE_TARGET_DIR)/usr/bin/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(PCRE_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(PCRE_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	-rm -rf $(PCRE_TARGET_DIR)/usr/share
	cp -a -f $(PCRE_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(PCRE_DIR)/.build


build: $(PCRE_DIR)/.build

clean:
	make -C $(PCRE_DIR) clean
	rm -rf $(PCRE_TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/lib/libpcre*
	rm -rf $(BT_STAGING_DIR)/usr/include/pcre*
	rm -f $(PCRE_DIR)/.build
	rm -f $(PCRE_DIR)/.configured

srcclean: clean
	rm -rf $(PCRE_DIR)
	rm -f $(PCRE_DIR)/.source
