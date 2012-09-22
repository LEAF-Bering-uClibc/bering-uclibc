#############################################################
#
# libpcap
#
#############################################################

include $(MASTERMAKEFILE)

LIBPCAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBPCAP_SOURCE) 2>/dev/null )
LIBPCAP_TARGET_DIR:=$(BT_BUILD_DIR)/libpcap
export CC=$(TARGET_CC)

$(LIBPCAP_DIR)/.source:
	zcat $(LIBPCAP_SOURCE) | tar -xvf -
	touch $(LIBPCAP_DIR)/.source

$(LIBPCAP_DIR)/.configured: $(LIBPCAP_DIR)/.source
	(cd $(LIBPCAP_DIR); \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--prefix=/usr \
			--enable-ipv6 \
			--with-pcap=linux \
			--with-dag=no \
			--with-septel=no );
	touch $(LIBPCAP_DIR)/.configured

source: $(LIBPCAP_DIR)/.source


$(LIBPCAP_DIR)/.build: $(LIBPCAP_DIR)/.configured
	mkdir -p $(LIBPCAP_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_TOOLCHAIN_DIR)/usr/bin
	$(MAKE) $(MAKEOPTS) -C $(LIBPCAP_DIR) shared
	$(MAKE) $(MAKEOPTS) DESTDIR=$(LIBPCAP_TARGET_DIR) -C $(LIBPCAP_DIR) install install-shared
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBPCAP_TARGET_DIR)/usr/lib/*
	# Fix up generated pcap-config (Trac ticket #25)
	perl -i -p -e "s,/usr,$(BT_STAGING_DIR)/usr,g" $(LIBPCAP_TARGET_DIR)/usr/bin/pcap-config
	-rm -rf $(LIBPCAP_TARGET_DIR)/usr/share
	cp -a $(LIBPCAP_TARGET_DIR)/* $(BT_STAGING_DIR)/
	cp -a $(LIBPCAP_TARGET_DIR)/usr/bin/pcap-config $(BT_TOOLCHAIN_DIR)/usr/bin/pcap-config
	touch $(LIBPCAP_DIR)/.build

build: $(LIBPCAP_DIR)/.build

clean:
	-rm $(LIBPCAP_DIR)/.build
	-rm -rf $(LIBPCAP_TARGET_DIR)
	-$(MAKE) -C $(LIBPCAP_DIR) clean
	-rm -f $(BT_STAGING_DIR)/usr/lib/libpcap.*
	-rm -f $(BT_STAGING_DIR)/usr/include/pcap.h
	-rm -f $(BT_STAGING_DIR)/usr/include/pcap-namedb.h
	-rm -f $(BT_STAGING_DIR)/usr/include/pcap-bpf.h

srcclean:
	-rm -rf $(LIBPCAP_DIR)
