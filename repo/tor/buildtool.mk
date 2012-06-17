# makefile for tor
include $(MASTERMAKEFILE)

TOR_DIR:=tor-0.2.2.37
TOR_TARGET_DIR:=$(BT_BUILD_DIR)/tor

$(TOR_DIR)/.source:
	zcat $(TOR_SOURCE) | tar -xvf -
	touch $(TOR_DIR)/.source

source: $(TOR_DIR)/.source

$(TOR_DIR)/.configured: $(TOR_DIR)/.source
	(cd $(TOR_DIR) ;  ./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr \
	--sysconfdir=/etc)
	touch $(TOR_DIR)/.configured

$(TOR_DIR)/.build: $(TOR_DIR)/.configured
	mkdir -p $(TOR_TARGET_DIR)
	mkdir -p $(TOR_TARGET_DIR)/etc/init.d
	mkdir -p $(TOR_TARGET_DIR)/etc/tor
	mkdir -p $(TOR_TARGET_DIR)/usr/bin
	mkdir -p $(TOR_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(TOR_DIR)
	cp -aL tor.init $(TOR_TARGET_DIR)/etc/init.d/tor
#	cp -a $(TOR_DIR)/contrib/tor-tsocks.conf $(TOR_TARGET_DIR)/etc/tor
	cp -aL torrc $(TOR_TARGET_DIR)/etc/tor
	cp -a $(TOR_DIR)/src/or/tor $(TOR_TARGET_DIR)/usr/sbin
	cp -a $(TOR_DIR)/src/tools/tor-resolve $(TOR_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TOR_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TOR_TARGET_DIR)/usr/sbin/*
	cp -a $(TOR_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TOR_DIR)/.build

build: $(TOR_DIR)/.build

clean:
	make -C $(TOR_DIR) clean
	rm -rf $(TOR_TARGET_DIR)
	rm -rf $(TOR_DIR)/.build
	rm -rf $(TOR_DIR)/.configured

srcclean: clean
	rm -rf $(TOR_DIR)
	rm -rf $(TOR_DIR)/.source
