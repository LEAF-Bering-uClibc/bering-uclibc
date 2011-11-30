#############################################################
#
# libnet for syslog-ng
#
#############################################################

include $(MASTERMAKEFILE)
LIBNET_DIR:=libnet
LIBNET_TARGET_DIR:=$(BT_BUILD_DIR)/libnet

source:
	zcat $(LIBNET_SOURCE) | tar -xvf -
	zcat $(BT_TOOLS_DIR)/config.sub.gz > $(LIBNET_DIR)/config.sub
	cat $(LIBNET_PATCH1) | patch -d $(LIBNET_DIR) -p0

$(LIBNET_DIR)/Makefile: $(LIBNET_DIR)/configure
	(cd $(LIBNET_DIR); autoconf && \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr );

build: $(LIBNET_DIR)/Makefile
	mkdir -p $(LIBNET_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBNET_DIR)
	$(MAKE) $(MAKEOPTS) DESTDIR=$(LIBNET_TARGET_DIR) -C $(LIBNET_DIR) install
	cp -a $(LIBNET_TARGET_DIR)/* $(BT_STAGING_DIR)/

#build: $(LIBPCAP_DIR)/.build

clean:
	echo $(PATH)
	-rm $(LIBNET_DIR)/.build
	rm -rf $(LIBNET_TARGET_DIR)
	$(MAKE) -C $(LIBNET_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libnet.a
	rm -f $(BT_STAGING_DIR)/usr/include/libnet.h
	rm -rf $(BT_STAGING_DIR)/usr/include/libnet/*

srcclean:
	rm -rf $(LIBNET_DIR)
