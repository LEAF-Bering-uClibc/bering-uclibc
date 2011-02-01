#############################################################
#
# libpcap
#
#############################################################

include $(MASTERMAKEFILE)
LIBDNET_DIR:=libdnet-1.11
LIBDNET_TARGET_DIR:=$(BT_BUILD_DIR)/libdnet
export CC=$(TARGET_CC)

source:
	zcat $(LIBDNET_SOURCE) | tar -xvf - 	
#	cat $(LIBPCAP_PATCH1) | patch -d $(LIBPCAP_DIR) -p1  

$(LIBDNET_DIR)/Makefile: $(LIBDNET_DIR)/configure
	(cd $(LIBDNET_DIR); ac_cv_linux_vers=2  \
		CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS=$(CFLAGS) \
		./configure \
			--build=i686-pc-linux-gnu \
			--target=i686-pc-linux-gnu \
			--prefix=/usr \
			--without-check );
	
#source: $(LIBPCAP_DIR)/.source


build: $(LIBDNET_DIR)/Makefile
	mkdir -p $(LIBDNET_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBDNET_DIR) 
	$(MAKE) DESTDIR=$(LIBDNET_TARGET_DIR) -C $(LIBDNET_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBDNET_TARGET_DIR)/usr/lib/libdnet.1.0.1
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBDNET_TARGET_DIR)/usr/sbin/dnet
	rm -rf $(LIBDNET_TARGET_DIR)/usr/man
	cp -a $(LIBDNET_TARGET_DIR)/* $(BT_STAGING_DIR)

#build: $(LIBPCAP_DIR)/.build

clean:
	echo $(PATH)
	-rm $(LIBDNET_DIR)/.build
	rm -rf $(LIBDNET_TARGET_DIR)
	$(MAKE) -C $(LIBDNET_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libdnet
	rm -f $(BT_STAGING_DIR)/usr/lib/libdnet.*
	rm -f $(BT_STAGING_DIR)/usr/include/dnet.h
	rm -rf $(BT_STAGING_DIR)/usr/include/dnet
	rm -f $(BT_STAGING_DIR)/usr/bin/dnet-config
	rm -f $(BT_STAGING_DIR)/usr/sbin/dnet
	
srcclean:
	rm -rf $(LIBDNET_DIR)
