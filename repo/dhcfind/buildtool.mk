# makefile

PKG_DIR=.
PKG_TARGET_DIR:=$(BT_BUILD_DIR)/dhcfind

source:

build:
	mkdir -p $(PKG_TARGET_DIR)
	mkdir -p $(PKG_TARGET_DIR)/usr/bin
	mkdir -p $(PKG_TARGET_DIR)/etc/cron.d
	cp -aL dhcfind.cron $(PKG_TARGET_DIR)/etc/cron.d/dhcfind
	cp -aL dhcfind $(PKG_TARGET_DIR)/usr/bin
	cp -aL dhcfind.conf $(PKG_TARGET_DIR)/etc
	cp -a $(PKG_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	rm -rf $(PKG_TARGET_DIR)

srcclean: clean
	rm -rf $(PKG_DIR)
