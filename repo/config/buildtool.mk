# makefile for config
include $(MASTERMAKEFILE)

CONFIG_DIR=.
CONFIG_TARGET_DIR:=$(BT_BUILD_DIR)/config

$(CONFIG_DIR)/.source:
	touch $(CONFIG_DIR)/.source

source: $(CONFIG_DIR)/.source

build:
	mkdir -p $(CONFIG_TARGET_DIR)
	mkdir -p $(CONFIG_TARGET_DIR)/usr/bin
	mkdir -p $(CONFIG_TARGET_DIR)/usr/sbin
	mkdir -p $(CONFIG_TARGET_DIR)/etc
	cp -aL help $(CONFIG_TARGET_DIR)/usr/bin
	cp -aL hwdetect $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL pauseme $(CONFIG_TARGET_DIR)/usr/bin
	cp -aL with_storage $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL apkg $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL apkg.merge $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL apkg.mergefile $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL lrcfg.backup $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL config.cfg $(CONFIG_TARGET_DIR)/etc
	cp -aL lrcfg.conf $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL lrcfg.conf.packs $(CONFIG_TARGET_DIR)/usr/sbin
	cp -aL lrcfg $(CONFIG_TARGET_DIR)/usr/sbin
	cp -a $(CONFIG_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(CONFIG_DIR)/.build


clean:
	rm -rf $(CONFIG_TARGET_DIR)
	rm -f $(CONFIG_DIR)/.build
	rm -f $(CONFIG_DIR)/.configured

srcclean: clean
	rm -f $(CONFIG_DIR)/.source
