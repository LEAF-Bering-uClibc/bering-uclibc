###################################
# buildtool setup for libnfnetlink
###################################

#LIBNFNETLINK_DIR:=libnfnetlink-1.0.1
LIBNFNETLINK_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBNFNETLINK_SOURCE) 2>/dev/null )
LIBNFNETLINK_TARGET_DIR:=$(BT_BUILD_DIR)/libnfnetlink

$(LIBNFNETLINK_DIR)/.source:
	bzcat $(LIBNFNETLINK_SOURCE) |  tar -xvf -
	touch $(LIBNFNETLINK_DIR)/.source

$(LIBNFNETLINK_DIR)/.configured: $(LIBNFNETLINK_DIR)/.source
	(cd $(LIBNFNETLINK_DIR) ; ./configure --build=$(GNU_BUILD_NAME) --host=$(GNU_TARGET_NAME) --prefix=/usr )
	touch $(LIBNFNETLINK_DIR)/.configured

source: $(LIBNFNETLINK_DIR)/.source

$(LIBNFNETLINK_DIR)/.build: $(LIBNFNETLINK_DIR)/.configured
	mkdir -p $(LIBNFNETLINK_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include/libnfnetlink
	$(MAKE) $(MAKEOPTS) -C $(LIBNFNETLINK_DIR)
	$(MAKE) DESTDIR=$(LIBNFNETLINK_TARGET_DIR) -C $(LIBNFNETLINK_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNFNETLINK_TARGET_DIR)/usr/lib/libnfnetlink.so*
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(LIBNFNETLINK_TARGET_DIR)/usr/lib/*.la
	cp -ar $(LIBNFNETLINK_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
#	cp -ar $(LIBNFNETLINK_TARGET_DIR)/usr/lib/pkgconfig/* $(BT_STAGING_DIR)/usr/lib/pkgconfig/
	cp -a $(LIBNFNETLINK_TARGET_DIR)/usr/include/libnfnetlink/libnfnetlink.h $(BT_STAGING_DIR)/usr/include/libnfnetlink
	cp -a $(LIBNFNETLINK_TARGET_DIR)/usr/include/libnfnetlink/linux_nfnetlink_compat.h $(BT_STAGING_DIR)/usr/include/libnfnetlink
	cp -a $(LIBNFNETLINK_TARGET_DIR)/usr/include/libnfnetlink/linux_nfnetlink.h $(BT_STAGING_DIR)/usr/include/libnfnetlink
	touch $(LIBNFNETLINK_DIR)/.build

build: $(LIBNFNETLINK_DIR)/.build

clean:
	-rm $(LIBNFNETLINK_DIR)/.build
	rm -rf $(LIBNFNETLINK_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libnfnetlink.* 
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libnfnetlink.pc 
	rm -rf $(BT_STAGING_DIR)/usr/include/libnfnetlink
	$(MAKE) -C $(LIBNFNETLINK_DIR) clean
	
srcclean:
	rm -rf $(LIBNFNETLINK_DIR)

