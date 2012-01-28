# makefile for pmacctd
include $(MASTERMAKEFILE)

PMACCTD_DIR:=pmacct-0.12.5
PMACCTD_TARGET_DIR:=$(BT_BUILD_DIR)/pmacctd

$(PMACCTD_DIR)/.source:
	zcat $(PMACCTD_SOURCE) | tar -xvf -
	touch $(PMACCTD_DIR)/.source

source: $(PMACCTD_DIR)/.source

$(PMACCTD_DIR)/.configured: $(PMACCTD_DIR)/.source
	(cd $(PMACCTD_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure \
	--prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--enable-ipv6 \
	--enable-threads \
	--with-pcap-includes=$(BT_STAGING_DIR)/usr/include/ )
	touch $(PMACCTD_DIR)/.configured

$(PMACCTD_DIR)/.build: $(PMACCTD_DIR)/.configured
	mkdir -p $(PMACCTD_TARGET_DIR)
	mkdir -p $(PMACCTD_TARGET_DIR)/etc/pmacct
	mkdir -p $(PMACCTD_TARGET_DIR)/etc/init.d
	mkdir -p $(PMACCTD_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(PMACCTD_DIR) all
	cp -aL pmacct.init $(PMACCTD_TARGET_DIR)/etc/init.d/pmacct
	cp -aL pmacctd.conf $(PMACCTD_TARGET_DIR)/etc/pmacct
	cp -a $(PMACCTD_DIR)/src/pmacctd $(PMACCTD_TARGET_DIR)/usr/sbin
	cp -a $(PMACCTD_DIR)/src/pmacct $(PMACCTD_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PMACCTD_TARGET_DIR)/usr/sbin/*
	cp -a $(PMACCTD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PMACCTD_DIR)/.build

build: $(PMACCTD_DIR)/.build

clean:
	make -C $(PMACCTD_DIR) clean
	rm -rf $(PMACCTD_TARGET_DIR)
	rm -rf $(PMACCTD_DIR)/.build
	rm -rf $(PMACCTD_DIR)/.configured

srcclean: clean
	rm -rf $(PMACCTD_DIR)
