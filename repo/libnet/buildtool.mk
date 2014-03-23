#############################################################
#
# libnet for syslog-ng
#
#############################################################

LIBNET_TARGET_DIR:=$(BT_BUILD_DIR)/libnet
LIBNET_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBNET_SOURCE) 2>/dev/null )

source:
	zcat $(LIBNET_SOURCE) | tar -xvf -
	zcat $(BT_TOOLS_DIR)/config.sub.gz > $(LIBNET_DIR)/config.sub

$(LIBNET_DIR)/Makefile: $(LIBNET_DIR)/configure
	(cd $(LIBNET_DIR); autoconf && \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr );

build: $(LIBNET_DIR)/Makefile
	mkdir -p $(LIBNET_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBNET_DIR)
	$(MAKE) $(MAKEOPTS) DESTDIR=$(LIBNET_TARGET_DIR) -C $(LIBNET_DIR) install
	cp -a $(LIBNET_TARGET_DIR)/* $(BT_STAGING_DIR)/

clean:
	echo $(PATH)
	-rm $(LIBNET_DIR)/.build
	rm -rf $(LIBNET_TARGET_DIR)
	$(MAKE) -C $(LIBNET_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libnet.a
	rm -f $(BT_STAGING_DIR)/usr/include/libnet.h
	rm -rf $(BT_STAGING_DIR)/usr/include/libnet/*

srcclean: clean
	rm -rf $(LIBNET_DIR)
