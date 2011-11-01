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
	zcat $(LIBNET_CONFIG_SUB) > $(LIBNET_DIR)/config.sub
#	cat $(LIBPCAP_PATCH1) | patch -d $(LIBPCAP_DIR) -p1  

$(LIBNET_DIR)/Makefile: $(LIBNET_DIR)/configure
	(cd $(LIBNET_DIR); \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr );
	
#source: $(LIBPCAP_DIR)/.source


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
	rm -f $(TOOLCHAIN_DIR)/usr/lib/libnet.a
	rm -f $(TOOLCHAIN_DIR)/usr/include/libnet.h
	rm -rf $(TOOLCHAIN_DIR)/usr/include/libnet/*
	
srcclean:
	rm -rf $(LIBNET_DIR)
