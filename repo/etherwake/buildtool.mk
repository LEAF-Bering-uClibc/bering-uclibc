#############################################################
#
# etherwake
#
#############################################################

ETHERWAKE_DIR:=etherwake-1.08.orig
ETHERWAKE_TARGET_DIR:=$(BT_BUILD_DIR)/etherwake


$(ETHERWAKE_DIR)/.source:
	zcat $(ETHERWAKE_SOURCE) |  tar -xvf -
	zcat $(ETHERWAKE_PATCH1) | patch -d $(ETHERWAKE_DIR) -p1
	zcat $(ETHERWAKE_PATCH2) | patch -d $(ETHERWAKE_DIR) -p1
	touch $(ETHERWAKE_DIR)/.source

$(ETHERWAKE_DIR)/.build:
	mkdir -p $(ETHERWAKE_TARGET_DIR)
	mkdir -p $(ETHERWAKE_TARGET_DIR)/usr/sbin
	$(MAKE) -C $(ETHERWAKE_DIR) CC=$(TARGET_CC) CFLAGS="$(CFLAGS)"
	cp -a $(ETHERWAKE_DIR)/etherwake $(ETHERWAKE_TARGET_DIR)/usr/sbin/ether-wake
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ETHERWAKE_TARGET_DIR)/usr/sbin/*
	cp -a $(ETHERWAKE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ETHERWAKE_DIR)/.build

source: $(ETHERWAKE_DIR)/.source

build: $(ETHERWAKE_DIR)/.build

clean:
	-rm $(ETHERWAKE_DIR)/.build
	$(MAKE) -C $(ETHERWAKE_DIR) clean

srcclean:
	rm -rf $(ETHERWAKE_DIR)
