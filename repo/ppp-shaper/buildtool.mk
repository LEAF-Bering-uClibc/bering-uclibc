# makefile for qos-htb

PKG_DIR=.
PKG_TARGET_DIR:=$(BT_BUILD_DIR)/ppp-shaper

source:

build:
	mkdir -p $(PKG_TARGET_DIR)
	mkdir -p $(PKG_TARGET_DIR)/etc/ppp/ip-up.d
	mkdir -p $(PKG_TARGET_DIR)/etc/ppp/ip-down.d
	cp -aL ppp-up $(PKG_TARGET_DIR)/etc/ppp/ip-up.d
	cp -aL ppp-down $(PKG_TARGET_DIR)/etc/ppp/ip-down.d
	cp -aL shaper.conf $(PKG_TARGET_DIR)/etc/ppp
	cp -a $(PKG_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	rm -rf $(PKG_TARGET_DIR)

srcclean: clean
	rm -rf $(PKG_DIR)
