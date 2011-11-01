# makefile for ppp, ppp-filter, pppoe and pppoatm
include $(MASTERMAKEFILE)

PPP_DIR:=ppp-2.4.5
PPP_TARGET_DIR:=$(BT_BUILD_DIR)/ppp

$(PPP_DIR)/.source:
	zcat $(PPP_SOURCE) | tar -xvf -
	cat $(PPP_PATCH1) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH2) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH3) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH4) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH5) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH6) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH7) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH8) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH9) | patch -d $(PPP_DIR) -p1
	cat $(PPP_PATCH10) | patch -d $(PPP_DIR) -p1
	perl -i -p -e 's/3.8p/3.10/' $(PPP_DIR)/pppd/plugins/rp-pppoe/Makefile.linux
	touch $(PPP_DIR)/.source

source: $(PPP_DIR)/.source

$(PPP_DIR)/.configured: $(PPP_DIR)/.source
	(cd $(PPP_DIR) ; ./configure --prefix=/usr)
	touch $(PPP_DIR)/.configured

$(PPP_DIR)/.build: $(PPP_DIR)/.configured
	mkdir -p $(PPP_TARGET_DIR)
	mkdir -p $(PPP_TARGET_DIR)/etc/chatscripts
	mkdir -p $(PPP_TARGET_DIR)/etc/ppp
	mkdir -p $(PPP_TARGET_DIR)/etc/ppp/peers
	mkdir -p $(PPP_TARGET_DIR)/etc/radiusclient
	mkdir -p $(PPP_TARGET_DIR)/usr/bin
	mkdir -p $(PPP_TARGET_DIR)/usr/sbin
	mkdir -p $(PPP_TARGET_DIR)/usr/lib/pppd
	$(MAKE) -C $(PPP_DIR) clean
	make CC=$(TARGET_CC) $(MAKEOPTS) -C $(PPP_DIR) COPTS="$(BT_COPT_FLAGS)" \
		INCLUDEDIR=$(TOOLCHAIN_DIR)/usr/include FILTER= HAVE_INET6=y CBCP=
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPP_DIR)/pppd/pppd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPP_DIR)/pppstats/pppstats
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPP_DIR)/chat/chat
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPP_DIR)/pppd/plugins/pppoatm/pppoatm.so
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPP_DIR)/pppd/plugins/rp-pppoe/rp-pppoe.so
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPP_DIR)/pppd/plugins/rp-pppoe/pppoe-discovery
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPP_DIR)/pppd/plugins/radius/*.so
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPP_DIR)/pppd/plugins/pppol2tp/*.so
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPP_DIR)/pppd/plugins/*.so
	cp -aL poff $(PPP_TARGET_DIR)/usr/bin
	cp -aL plog $(PPP_TARGET_DIR)/usr/bin
	cp -aL pon $(PPP_TARGET_DIR)/usr/bin
	cp -a $(PPP_DIR)/pppd/pppd $(PPP_TARGET_DIR)/usr/sbin
	cp -a $(PPP_DIR)/pppstats/pppstats $(PPP_TARGET_DIR)/usr/sbin
	cp -a $(PPP_DIR)/chat/chat $(PPP_TARGET_DIR)/usr/sbin
	cp -a $(PPP_DIR)/pppd/plugins/pppoatm/pppoatm.so $(PPP_TARGET_DIR)/usr/lib/pppd
	cp -a $(PPP_DIR)/pppd/plugins/rp-pppoe/rp-pppoe.so $(PPP_TARGET_DIR)/usr/lib/pppd
	cp -a $(PPP_DIR)/pppd/plugins/rp-pppoe/pppoe-discovery $(PPP_TARGET_DIR)/usr/sbin
	cp -a $(PPP_DIR)/pppd/plugins/radius/*.so $(PPP_TARGET_DIR)/usr/lib/pppd
	cp -a $(PPP_DIR)/pppd/plugins/pppol2tp/*.so $(PPP_TARGET_DIR)/usr/lib/pppd
	cp -a $(PPP_DIR)/etc.ppp/chap-secrets $(PPP_TARGET_DIR)/etc/ppp
	cp -aL options $(PPP_TARGET_DIR)/etc/ppp
	cp -aL pap-secrets $(PPP_TARGET_DIR)/etc/ppp
	cp -aL ip-up $(PPP_TARGET_DIR)/etc/ppp
	cp -aL ip-mod $(PPP_TARGET_DIR)/etc/ppp
	cp -aL ip-down $(PPP_TARGET_DIR)/etc/ppp
	cp -aL ipv6-up $(PPP_TARGET_DIR)/etc/ppp
	cp -aL ipv6-down $(PPP_TARGET_DIR)/etc/ppp
	cp -aL provider.chat $(PPP_TARGET_DIR)/etc/chatscripts/provider
	cp -aL provider.peer $(PPP_TARGET_DIR)/etc/ppp/peers/provider
	cp -aL dsl-provider.atm $(PPP_TARGET_DIR)/etc/ppp/peers/
	cp -aL dsl-provider.pppoe $(PPP_TARGET_DIR)/etc/ppp/peers/dsl-provider
	cp -a $(PPP_DIR)/pppd/plugins/radius/etc/radiusclient.conf $(PPP_TARGET_DIR)/etc/radiusclient
	cp -a $(PPP_DIR)/pppd/plugins/radius/etc/dictionary $(PPP_TARGET_DIR)/etc/radiusclient
	cp -a $(PPP_DIR)/pppd/plugins/radius/etc/dictionary.microsoft $(PPP_TARGET_DIR)/etc/radiusclient
	cp -a $(PPP_DIR)/pppd/plugins/radius/etc/servers $(PPP_TARGET_DIR)/etc/radiusclient
	cp -a $(PPP_DIR)/pppd/plugins/radius/etc/port-id-map $(PPP_TARGET_DIR)/etc/radiusclient

	$(MAKE) -C $(PPP_DIR) clean
#	make CC=$(TARGET_CC) -C $(PPP_DIR) COPTS="$(BT_COPT_FLAGS)" -I$(TOOLCHAIN_DIR)/usr/include" FILTER=y HAVE_INET6=y CBCP=
	make CC=$(TARGET_CC) -C $(PPP_DIR) COPTS="$(BT_COPT_FLAGS)" INCLUDEDIR=$(TOOLCHAIN_DIR)/usr/include FILTER=y HAVE_INET6=y CBCP=
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPP_DIR)/pppd/pppd
	cp -a $(PPP_DIR)/pppd/pppd $(PPP_TARGET_DIR)/usr/sbin/pppd-filter
	cp -a $(PPP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PPP_DIR)/.build

build: $(PPP_DIR)/.build

clean:
	rm -rf $(PPP_TARGET_DIR)
	$(MAKE) -C $(PPP_DIR) clean
	rm -f $(PPP_DIR)/.build
	rm -f $(PPP_DIR)/.configured

srcclean: clean
	rm -rf $(PPP_DIR)
	rm -f $(PPP_DIR)/.source
