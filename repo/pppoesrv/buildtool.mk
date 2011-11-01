include $(MASTERMAKEFILE)
PPPOESRV_DIR:=rp-pppoe-3.10
PPPOESRV_BUILD_DIR:=$(BT_BUILD_DIR)/pppoesrv

$(PPPOESRV_DIR)/.source:
	zcat $(PPPOESRV_SOURCE) |  tar -xvf -
	touch $(PPPOESRV_DIR)/.source

source: $(PPPOESRV_DIR)/.source

$(PPPOESRV_DIR)/.configured: $(PPPOESRV_DIR)/.source
	(cd $(PPPOESRV_DIR)/src ; \
		PPPD=/usr/sbin/pppd \
		./configure --disable-plugin --disable-debugging --host=$(GNU_TARGET_NAME))
	touch $(PPPOESRV_DIR)/.configured

$(PPPOESRV_DIR)/.build: $(PPPOESRV_DIR)/.configured
	mkdir -p $(PPPOESRV_BUILD_DIR)/usr/sbin
	mkdir -p $(PPPOESRV_BUILD_DIR)/etc/ppp
	mkdir -p $(PPPOESRV_BUILD_DIR)/etc/default
	mkdir -p $(PPPOESRV_BUILD_DIR)/etc/init.d
	$(MAKE) $(MAKEOPTS) -C $(PPPOESRV_DIR)/src PLUGIN_DIR=/usr/lib/pppd \
		DEFINES="-DHAVE_LINUX_KERNEL_PPPOE" pppoe-server pppoe-relay
	cp $(PPPOESRV_DIR)/src/pppoe-server $(PPPOESRV_BUILD_DIR)/usr/sbin/
	cp $(PPPOESRV_DIR)/src/pppoe-relay $(PPPOESRV_BUILD_DIR)/usr/sbin/
	cp -aL $(PPPOESRV_OPTIONS) $(PPPOESRV_BUILD_DIR)/etc/ppp/
	cp -aL $(PPPOESRV_DEFAULT) $(PPPOESRV_BUILD_DIR)/etc/default/pppoe-server
	cp -aL $(PPPOESRV_INITD)   $(PPPOESRV_BUILD_DIR)/etc/init.d/pppoe-server
	cp -aL $(PPPOERLY_DEFAULT) $(PPPOESRV_BUILD_DIR)/etc/default/pppoe-relay
	cp -aL $(PPPOERLY_INITD)   $(PPPOESRV_BUILD_DIR)/etc/init.d/pppoe-relay
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPPOESRV_BUILD_DIR)/usr/sbin/*
	cp -a $(PPPOESRV_BUILD_DIR)/* $(BT_STAGING_DIR)
	touch $(PPPOESRV_DIR)/.build

build: $(PPPOESRV_DIR)/.build

clean: 
	-$(MAKE) -C $(PPPOESRV_DIR)/src distclean
	rm -f $(BT_STAGING_DIR)/usr/sbin/pppoe-server
	rm -f $(BT_STAGING_DIR)/etc/ppp/pppoe-server-options
	rm -f $(BT_STAGING_DIR)/etc/default/pppoe-server
	rm -f $(BT_STAGING_DIR)/etc/init.d/pppoe-server
	rm -f $(BT_STAGING_DIR)/usr/sbin/pppoe-relay
	rm -f $(BT_STAGING_DIR)/etc/default/pppoe-relay
	rm -f $(BT_STAGING_DIR)/etc/init.d/pppoe-relay
	-rmdir $(BT_STAGING_DIR)/etc/init.d
	-rmdir $(BT_STAGING_DIR)/etc/ppp
	rm -f $(PPPOESRV_DIR)/.build $(PPPOESRV_DIR)/.configured

srcclean: clean
	rm -rf $(PPPOESRV_DIR)
