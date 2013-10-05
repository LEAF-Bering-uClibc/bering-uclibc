# makefile for bridge

BRIDGE-UTILS_DIR:=bridge-utils-1.5
BRIDGE-UTILS_TARGET_DIR:=$(BT_BUILD_DIR)/bridge

$(BRIDGE-UTILS_DIR)/.source:
	zcat $(BRIDGE-UTILS_SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -d $(BRIDGE-UTILS_DIR) -p1
	touch $(BRIDGE-UTILS_DIR)/.source

source: $(BRIDGE-UTILS_DIR)/.source

$(BRIDGE-UTILS_DIR)/.configured: $(BRIDGE-UTILS_DIR)/.source
	(cd $(BRIDGE-UTILS_DIR) ; autoreconf -i -f ;\
	./configure --prefix=/usr --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-linux-headers=$(BT_TOOLCHAIN_DIR)/include )
	touch $(BRIDGE-UTILS_DIR)/.configured

$(BRIDGE-UTILS_DIR)/.build: $(BRIDGE-UTILS_DIR)/.configured
	mkdir -p $(BRIDGE-UTILS_TARGET_DIR)
	mkdir -p $(BRIDGE-UTILS_TARGET_DIR)/usr/sbin
	mkdir -p $(BRIDGE-UTILS_TARGET_DIR)/etc/network/if-pre-up.d
	mkdir -p $(BRIDGE-UTILS_TARGET_DIR)/etc/network/if-post-down.d
	mkdir -p $(BRIDGE-UTILS_TARGET_DIR)/etc/network/if-up.d
	make $(MAKEOPTS) -C $(BRIDGE-UTILS_DIR) all
	cp -a $(BRIDGE-UTILS_DIR)/brctl/brctl $(BRIDGE-UTILS_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BRIDGE-UTILS_TARGET_DIR)/usr/sbin/*
	cp -aL bridge_if-pre-up $(BRIDGE-UTILS_TARGET_DIR)/etc/network/if-pre-up.d/bridge
	cp -aL bridge_if-post-down $(BRIDGE-UTILS_TARGET_DIR)/etc/network/if-post-down.d/bridge
	cp -aL bridge_if-up $(BRIDGE-UTILS_TARGET_DIR)/etc/network/if-up.d/bridge
	cp -a $(BRIDGE-UTILS_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(BRIDGE-UTILS_DIR)/.build

build: $(BRIDGE-UTILS_DIR)/.build

clean:
	make -C $(BRIDGE-UTILS_DIR) clean
	rm -rf $(BRIDGE-UTILS_TARGET_DIR)
	rm -f $(BRIDGE-UTILS_DIR)/.build
	rm -f $(BRIDGE-UTILS_DIR)/.configured

srcclean: clean
	rm -rf $(BRIDGE-UTILS_DIR)
