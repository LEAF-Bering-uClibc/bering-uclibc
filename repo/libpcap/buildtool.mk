#############################################################
#
# libpcap
#
#############################################################

include $(MASTERMAKEFILE)

LIBPCAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBPCAP_SOURCE) 2>/dev/null )
ifeq ($(LIBPCAP_DIR),)
LIBPCAP_DIR:=$(shell cat DIRNAME)
endif
LIBPCAP_TARGET_DIR:=$(BT_BUILD_DIR)/libpcap
export CC=$(TARGET_CC)

$(LIBPCAP_DIR)/.source:
	zcat $(LIBPCAP_SOURCE) | tar -xvf - 	
	echo $(LIBPCAP_DIR) > DIRNAME
	touch $(LIBPCAP_DIR)/.source

$(LIBPCAP_DIR)/.configured: $(LIBPCAP_DIR)/.source
	(cd $(LIBPCAP_DIR); ac_cv_linux_vers=2  \
		./configure \
			--build=i386-pc-linux-gnu \
			--target=i386-pc-linux-gnu \
			--prefix=/usr \
			--enable-ipv6 \
			--with-pcap=linux \
			--with-dag=no \
			--with-septel=no );
	touch $(LIBPCAP_DIR)/.configured
	
source: $(LIBPCAP_DIR)/.source


$(LIBPCAP_DIR)/.build: $(LIBPCAP_DIR)/.configured
	mkdir -p $(LIBPCAP_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBPCAP_DIR) shared
	$(MAKE) DESTDIR=$(LIBPCAP_TARGET_DIR) -C $(LIBPCAP_DIR) install
	$(MAKE) DESTDIR=$(LIBPCAP_TARGET_DIR) -C $(LIBPCAP_DIR) install-shared
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBPCAP_TARGET_DIR)/usr/lib/*
	ln -sf libpcap.so.1.1.1 $(LIBPCAP_TARGET_DIR)/usr/lib/libpcap.so
	# Fix up generated pcap-config (Trac ticket #25)
	perl -i -p -e "s,/usr,$(BT_STAGING_DIR)/usr,g" $(LIBPCAP_TARGET_DIR)/usr/bin/pcap-config
	cp -a $(LIBPCAP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBPCAP_DIR)/.build

build: $(LIBPCAP_DIR)/.build

clean:
	echo $(PATH)
	-rm $(LIBPCAP_DIR)/.build
	rm -rf $(LIBPCAP_TARGET_DIR)
	$(MAKE) -C $(LIBPCAP_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libpcap.a
	rm -f $(BT_STAGING_DIR)/usr/lib/libpcap.so*
	rm -f $(BT_STAGING_DIR)/usr/include/pcap.h
	rm -f $(BT_STAGING_DIR)/usr/include/pcap-namedb.h
	rm -f $(BT_STAGING_DIR)/usr/include/pcap-bpf.h
	
srcclean:
	rm -rf $(LIBPCAP_DIR)
	-rm DIRNAME

