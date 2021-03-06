#############################################################
#
# Hostap daemon
#
#############################################################

HOSTAPD_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(HOSTAPD_SOURCE) 2>/dev/null )
HOSTAPD_TARGET_DIR:=$(BT_BUILD_DIR)/hostapd

$(HOSTAPD_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(HOSTAPD_SOURCE)
	cat $(HOSTAPD_PATCH2) | patch -d $(HOSTAPD_DIR) -p1
	cp defconfig .config
	echo "CFLAGS += -I$(BT_STAGING_DIR)/usr/include/libnl3/" >> .config
	echo "CONFIG_LIBNL32=y" >> .config
	sed -i 's:/usr/include/libnl3:$(BT_STAGING_DIR)/usr/include/libnl3:' $(HOSTAPD_DIR)/src/drivers/drivers.mak 
	touch $(HOSTAPD_DIR)/.source

$(HOSTAPD_DIR)/.build: $(HOSTAPD_DIR)/.source
	-mkdir -p $(HOSTAPD_TARGET_DIR)/usr/bin
	-mkdir -p $(HOSTAPD_TARGET_DIR)/usr/sbin
	-mkdir -p $(HOSTAPD_TARGET_DIR)/etc/hostapd
	-mkdir -p $(HOSTAPD_TARGET_DIR)/etc/default
	-mkdir -p $(HOSTAPD_TARGET_DIR)/etc/init.d
	cp -a .config $(HOSTAPD_DIR)/hostapd/
	make $(MAKEOPTS) CC=$(TARGET_CC) -I$(BT_STAGING_DIR)/usr/include/libnl3/ -C $(HOSTAPD_DIR)/hostapd
	cp $(HOSTAPD_DIR)/hostapd/hostapd $(HOSTAPD_TARGET_DIR)/usr/sbin/
	cp $(HOSTAPD_DIR)/hostapd/hostapd_cli $(HOSTAPD_TARGET_DIR)/usr/bin/
	cp $(HOSTAPD_DIR)/hostapd/hostapd.deny $(HOSTAPD_TARGET_DIR)/etc/hostapd/deny
	cp $(HOSTAPD_DIR)/hostapd/hostapd.accept $(HOSTAPD_TARGET_DIR)/etc/hostapd/accept
	cp $(HOSTAPD_DIR)/hostapd/hostapd.conf $(HOSTAPD_TARGET_DIR)/etc/hostapd/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HOSTAPD_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HOSTAPD_TARGET_DIR)/usr/bin/*
	cp -aL hostapd.default $(HOSTAPD_TARGET_DIR)/etc/default/hostapd
	cp -aL hostapd.init $(HOSTAPD_TARGET_DIR)/etc/init.d/hostapd
	cp -a $(HOSTAPD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(HOSTAPD_DIR)/.build

source: $(HOSTAPD_DIR)/.source

build: $(HOSTAPD_DIR)/.build

clean:
	make -C $(HOSTAPD_DIR)/hostapd clean
	rm $(HOSTAPD_DIR)/.build
	rm -rf $(HOSTAPD_TARGET_DIR)

srcclean: clean
	rm -rf $(HOSTAPD_DIR)
	rm -rf .config
