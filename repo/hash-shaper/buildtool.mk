# makefile for hash shaper

PKG_DIR=.
PKG_TARGET_DIR:=$(BT_BUILD_DIR)/hash-shaper

source:

build:
	mkdir -p $(PKG_TARGET_DIR)
	mkdir -p $(PKG_TARGET_DIR)/usr/sbin
	mkdir -p $(PKG_TARGET_DIR)/etc/init.d
	cp -aL hsh $(PKG_TARGET_DIR)/etc/init.d
	cp -aL hsh.sh $(PKG_TARGET_DIR)/usr/sbin
	cp -aL hsh.conf $(PKG_TARGET_DIR)/etc
	cp -a $(PKG_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	rm -rf $(PKG_TARGET_DIR)

srcclean: clean
	rm -rf $(PKG_DIR)
