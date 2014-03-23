######################################################
# makefile for libnetfilter_acct
######################################################

LIBNETFILTER_ACCT_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBNETFILTERACCT_SOURCE) 2>/dev/null)
LIBNETFILTER_ACCT_TARGET_DIR:=$(BT_BUILD_DIR)/libnetfilter_acct

$(LIBNETFILTER_ACCT_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBNETFILTERACCT_SOURCE) 
	touch $(LIBNETFILTER_ACCT_DIR)/.source

$(LIBNETFILTER_ACCT_DIR)/.configured: $(LIBNETFILTER_ACCT_DIR)/.source
	(cd $(LIBNETFILTER_ACCT_DIR) ; ./configure --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) --prefix=/usr )
	touch $(LIBNETFILTER_ACCT_DIR)/.configured

source: $(LIBNETFILTER_ACCT_DIR)/.source

$(LIBNETFILTER_ACCT_DIR)/.build: $(LIBNETFILTER_ACCT_DIR)/.configured
	mkdir -p $(LIBNETFILTER_ACCT_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include/libnetfilter_acct
	$(MAKE) -C $(LIBNETFILTER_ACCT_DIR)
	$(MAKE) DESTDIR=$(LIBNETFILTER_ACCT_TARGET_DIR) -C $(LIBNETFILTER_ACCT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNETFILTER_ACCT_TARGET_DIR)/usr/lib/libnetfilter_acct.so*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBNETFILTER_ACCT_TARGET_DIR)/usr/lib/*.la
	cp -a $(LIBNETFILTER_ACCT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBNETFILTER_ACCT_DIR)/.build

build: $(LIBNETFILTER_ACCT_DIR)/.build

clean:
	-rm $(LIBNETFILTER_ACCT_DIR)/.build
	rm -rf $(LIBNETFILTER_ACCT_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libnetfilter_acct.*
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libnetfilter_acct.*
	rm -rf $(BT_STAGING_DIR)/usr/include/libnetfilter_acct
	$(MAKE) -C $(LIBNETFILTER_ACCT_DIR) clean

srcclean: clean
	rm -rf $(LIBNETFILTER_ACCT_DIR)
