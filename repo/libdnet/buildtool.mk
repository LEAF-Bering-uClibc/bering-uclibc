#############################################################
#
# libdnet
#
#############################################################

include $(MASTERMAKEFILE)
LIBDNET_DIR:=libdnet-1.11
LIBDNET_TARGET_DIR:=$(BT_BUILD_DIR)/libdnet
export CC=$(TARGET_CC)

source: $(LIBDNET_DIR)/configure

$(LIBDNET_DIR)/configure:
	zcat $(LIBDNET_SOURCE) | tar -xvf -
	zcat $(BT_TOOLS_DIR)/config.sub.gz >$(LIBDNET_DIR)/config/config.sub

$(LIBDNET_DIR)/Makefile: $(LIBDNET_DIR)/configure
	(cd $(LIBDNET_DIR); \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr \
			--without-check );

build: $(LIBDNET_DIR)/Makefile
	mkdir -p $(LIBDNET_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBDNET_DIR)
	$(MAKE) DESTDIR=$(LIBDNET_TARGET_DIR) -C $(LIBDNET_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBDNET_TARGET_DIR)/usr/lib/libdnet.1.0.1
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBDNET_TARGET_DIR)/usr/sbin/dnet
	rm -rf $(LIBDNET_TARGET_DIR)/usr/man
	cp -a $(LIBDNET_TARGET_DIR)/* $(BT_STAGING_DIR)

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
