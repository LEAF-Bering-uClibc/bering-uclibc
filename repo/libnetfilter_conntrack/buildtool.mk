include $(MASTERMAKEFILE)
LIBNETFILTER_CONNTRACK_DIR:=libnetfilter_conntrack-1.0.0
LIBNETFILTER_CONNTRACK_TARGET_DIR:=$(BT_BUILD_DIR)/libnetfilter_conntrack
export CC=$(TARGET_CC)
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment 

$(LIBNETFILTER_CONNTRACK_DIR)/.source: 		
	bzcat $(LIBNETFILTERCONNTRACK_SOURCE) |  tar -xvf - 	
	touch $(LIBNETFILTER_CONNTRACK_DIR)/.source

$(LIBNETFILTER_CONNTRACK_DIR)/.configured: $(LIBNETFILTER_CONNTRACK_DIR)/.source
#	(cd $(LIBNETFILTER_CONNTRACK_DIR) ; export LIBNFNETLINK_LIBS=-L$(BT_STAGING_DIR)/usr/lib; \
#	export LIBNFNETLINK_CFLAGS="-I$(BT_STAGING_DIR)/usr/include"; ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --prefix=/usr )
#	touch $(LIBNETFILTER_CONNTRACK_DIR)/.configured

	(cd $(LIBNETFILTER_CONNTRACK_DIR) ; ./configure --build=$(GNU_BUILD_NAME) --host=$(GNU_TARGET_NAME) --prefix=/usr )
	touch $(LIBNETFILTER_CONNTRACK_DIR)/.configured



source: $(LIBNETFILTER_CONNTRACK_DIR)/.source

$(LIBNETFILTER_CONNTRACK_DIR)/.build: $(LIBNETFILTER_CONNTRACK_DIR)/.configured
	mkdir -p $(LIBNETFILTER_CONNTRACK_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include/libnetfilter_conntrack
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_DIR) 	
	$(MAKE) DESTDIR=$(LIBNETFILTER_CONNTRACK_TARGET_DIR) -C $(LIBNETFILTER_CONNTRACK_DIR) install
	cp -a $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/usr/lib/libnetfilter_conntrack.so* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/usr/include/libnetfilter_conntrack/* $(BT_STAGING_DIR)/usr/include/libnetfilter_conntrack
	cp -a $(LIBNETFILTER_CONNTRACK_TARGET_DIR)/usr/lib/pkgconfig/libnetfilter_conntrack.pc $(BT_STAGING_DIR)/usr/lib/pkgconfig
	touch $(LIBNETFILTER_CONNTRACK_DIR)/.build

build: $(LIBNETFILTER_CONNTRACK_DIR)/.build

clean:
	-rm $(LIBNETFILTER_CONNTRACK_DIR)/.build
	rm -rf $(LIBNETFILTER_CONNTRACK_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libnetfilter_conntrack.* 
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libnetfilter_conntrack.* 
	rm -f $(BT_STAGING_DIR)/usr/include/libnetfilter_conntrack/*
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_DIR) clean
	
srcclean:
	rm -rf $(LIBNETFILTER_CONNTRACK_DIR)

