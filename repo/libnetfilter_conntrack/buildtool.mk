## makefile for libnetfilter_conntrack

LIBNETFILTER_CONNTRACK_DIR:=libnetfilter_conntrack-1.0.2
LIBNETFILTER_CONNTRACK_TARGET_DIR:=$(BT_BUILD_DIR)/libnetfilter_conntrack

$(LIBNETFILTER_CONNTRACK_DIR)/.source:
	bzcat $(LIBNETFILTERCONNTRACK_SOURCE) |  tar -xvf -
	touch $(LIBNETFILTER_CONNTRACK_DIR)/.source

$(LIBNETFILTER_CONNTRACK_DIR)/.configured: $(LIBNETFILTER_CONNTRACK_DIR)/.source
	(cd $(LIBNETFILTER_CONNTRACK_DIR) ; ./configure --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) --prefix=/usr )
	touch $(LIBNETFILTER_CONNTRACK_DIR)/.configured

source: $(LIBNETFILTER_CONNTRACK_DIR)/.source

$(LIBNETFILTER_CONNTRACK_DIR)/.build: $(LIBNETFILTER_CONNTRACK_DIR)/.configured
	mkdir -p $(LIBNETFILTER_CONNTRACK_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include/libnetfilter_conntrack
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_DIR)
	$(MAKE) DESTDIR=$(LIBNETFILTER_CONNTRACK_TARGET_DIR) -C $(LIBNETFILTER_CONNTRACK_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/usr/lib/libnetfilter_conntrack.so*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	cp -a $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBNETFILTER_CONNTRACK_DIR)/.build

build: $(LIBNETFILTER_CONNTRACK_DIR)/.build

clean:
	-rm $(LIBNETFILTER_CONNTRACK_DIR)/.build
	rm -rf $(LIBNETFILTER_CONNTRACK_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libnetfilter_conntrack.*
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libnetfilter_conntrack.*
	rm -rf $(BT_STAGING_DIR)/usr/include/libnetfilter_conntrack
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_DIR) clean

srcclean:
	rm -rf $(LIBNETFILTER_CONNTRACK_DIR)
