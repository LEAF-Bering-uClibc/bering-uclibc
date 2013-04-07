## makefile for libnetfilter_cttimeout

LIBNETFILTER_CTTIMEOUT_DIR:=libnetfilter_cttimeout-1.0.0
LIBNETFILTER_CTTIMEOUT_TARGET_DIR:=$(BT_BUILD_DIR)/libnetfilter_cttimeout

$(LIBNETFILTER_CTTIMEOUT_DIR)/.source:
	bzcat $(LIBNETFILTERCTTIMEOUT_SOURCE) |  tar -xvf -
	touch $(LIBNETFILTER_CTTIMEOUT_DIR)/.source

$(LIBNETFILTER_CTTIMEOUT_DIR)/.configured: $(LIBNETFILTER_CTTIMEOUT_DIR)/.source
	(cd $(LIBNETFILTER_CTTIMEOUT_DIR) ; ./configure --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) --prefix=/usr )
	touch $(LIBNETFILTER_CTTIMEOUT_DIR)/.configured

source: $(LIBNETFILTER_CTTIMEOUT_DIR)/.source

$(LIBNETFILTER_CTTIMEOUT_DIR)/.build: $(LIBNETFILTER_CTTIMEOUT_DIR)/.configured
	mkdir -p $(LIBNETFILTER_CTTIMEOUT_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include/libnetfilter_cttimeout
	$(MAKE) -C $(LIBNETFILTER_CTTIMEOUT_DIR)
	$(MAKE) DESTDIR=$(LIBNETFILTER_CTTIMEOUT_TARGET_DIR) -C $(LIBNETFILTER_CTTIMEOUT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNETFILTER_CTTIMEOUT_TARGET_DIR)/usr/lib/libnetfilter_cttimeout.so*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBNETFILTER_CTTIMEOUT_TARGET_DIR)/usr/lib/*.la
	cp -a $(LIBNETFILTER_CTTIMEOUT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBNETFILTER_CTTIMEOUT_DIR)/.build

build: $(LIBNETFILTER_CTTIMEOUT_DIR)/.build

clean:
	-rm $(LIBNETFILTER_CTTIMEOUT_DIR)/.build
	rm -rf $(LIBNETFILTER_CTTIMEOUT_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libnetfilter_cttimeout.*
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libnetfilter_cttimeout.*
	rm -rf $(BT_STAGING_DIR)/usr/include/libnetfilter_cttimeout
	$(MAKE) -C $(LIBNETFILTER_CTTIMEOUT_DIR) clean

srcclean:
	rm -rf $(LIBNETFILTER_CTTIMEOUT_DIR)
