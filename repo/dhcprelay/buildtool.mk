# makefile for dhcprelay
include $(MASTERMAKEFILE)

DHCPRELAY_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(DHCPRELAY_SOURCE) 2>/dev/null )
DHCPRELAY_TARGET_DIR:=$(BT_BUILD_DIR)/dhcprelay

$(DHCPRELAY_DIR)/.source:
	zcat $(DHCPRELAY_SOURCE) | tar -xvf -
	touch $(DHCPRELAY_DIR)/.source

source: $(DHCPRELAY_DIR)/.source

$(DHCPRELAY_DIR)/.configured: $(DHCPRELAY_DIR)/.source
	(cd $(DHCPRELAY_DIR) ; ./configure \
		--prefix=/usr \
		--build=$(GNU_BUILD_NAME) \
		--host=$(GNU_TARGET_NAME) )
	touch $(DHCPRELAY_DIR)/.configured

$(DHCPRELAY_DIR)/.build: $(DHCPRELAY_DIR)/.configured
	mkdir -p $(DHCPRELAY_TARGET_DIR)
	mkdir -p $(DHCPRELAY_TARGET_DIR)/etc/init.d
	mkdir -p $(DHCPRELAY_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(DHCPRELAY_DIR) all
	cp -aL dhcprelay.init $(DHCPRELAY_TARGET_DIR)/etc/init.d/dhcprelay
	cp -aL dhcprelay.conf $(DHCPRELAY_TARGET_DIR)/etc
	cp -a $(DHCPRELAY_DIR)/src/dhcprelay $(DHCPRELAY_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DHCPRELAY_TARGET_DIR)/usr/sbin/*
	cp -a $(DHCPRELAY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DHCPRELAY_DIR)/.build

build: $(DHCPRELAY_DIR)/.build

clean:
	make -C $(DHCPRELAY_DIR) clean
	rm -rf $(DHCPRELAY_TARGET_DIR)
	rm -rf $(DHCPRELAY_DIR)/.build
	rm -rf $(DHCPRELAY_DIR)/.configured

srcclean: clean
	rm -rf $(DHCPRELAY_DIR)
	rm -rf $(DHCPRELAY_DIR)/.source
