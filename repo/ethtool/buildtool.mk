# makefile for ethtool
include $(MASTERMAKEFILE)

ETHTOOL_DIR:=ethtool-2.6.37
ETHTOOL_TARGET_DIR:=$(BT_BUILD_DIR)/ethtool

$(ETHTOOL_DIR)/.source:
	zcat $(ETHTOOL_SOURCE) | tar -xvf -
	touch $(ETHTOOL_DIR)/.source

source: $(ETHTOOL_DIR)/.source

$(ETHTOOL_DIR)/.configured: $(ETHTOOL_DIR)/.source
	(cd $(ETHTOOL_DIR) ; ./configure \
	--build=$(GNU_BUILD_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--prefix=/usr)
	touch $(ETHTOOL_DIR)/.configured

$(ETHTOOL_DIR)/.build: $(ETHTOOL_DIR)/.configured
	mkdir -p $(ETHTOOL_TARGET_DIR)
	mkdir -p $(ETHTOOL_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(ETHTOOL_DIR)
	cp -a $(ETHTOOL_DIR)/ethtool $(ETHTOOL_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ETHTOOL_TARGET_DIR)/usr/sbin/*
	cp -a $(ETHTOOL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ETHTOOL_DIR)/.build

build: $(ETHTOOL_DIR)/.build

clean:
	make -C $(ETHTOOL_DIR) clean
	rm -rf $(ETHTOOL_TARGET_DIR)
	rm -f $(ETHTOOL_DIR)/.build
	rm -f $(ETHTOOL_DIR)/.configured

srcclean: clean
	rm -rf $(ETHTOOL_DIR)
	rm -f $(ETHTOOL_DIR)/.source
