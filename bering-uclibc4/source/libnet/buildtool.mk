#############################################################
#
# libpcap
#
#############################################################

include $(MASTERMAKEFILE)
LIBNET_DIR:=libnet
LIBNET_TARGET_DIR:=$(BT_BUILD_DIR)/libnet
export CC=$(TARGET_CC)

source:
	zcat $(LIBNET_SOURCE) | tar -xvf - 	
#	cat $(LIBPCAP_PATCH1) | patch -d $(LIBPCAP_DIR) -p1  

$(LIBNET_DIR)/Makefile: $(LIBNET_DIR)/configure
	(cd $(LIBNET_DIR); ac_cv_linux_vers=2  \
		./configure \
			--build=i686-pc-linux-gnu \
			--target=i686-pc-linux-gnu \
			--prefix=/usr );
	
#source: $(LIBPCAP_DIR)/.source


build: $(LIBNET_DIR)/Makefile
	mkdir -p $(LIBNET_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBNET_DIR) 
	$(MAKE) DESTDIR=$(LIBNET_TARGET_DIR) -C $(LIBNET_DIR) install
#	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNET_TARGET_DIR)/usr/lib/libnet
#	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBNET_TARGET_DIR)/usr/sbin/dnet
#	rm -rf $(LIBNET_TARGET_DIR)/usr/man
	cp -a $(LIBNET_TARGET_DIR)/* $(BT_STAGING_DIR)

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
