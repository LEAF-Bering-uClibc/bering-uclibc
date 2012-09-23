# makefile

PKG_DIR=.
PKG_TARGET_DIR:=$(BT_BUILD_DIR)/updater

source:

build:
	mkdir -p $(PKG_TARGET_DIR)
	mkdir -p $(PKG_TARGET_DIR)/usr/sbin
	mkdir -p $(PKG_TARGET_DIR)/sbin
	mkdir -p $(PKG_TARGET_DIR)/etc
	mkdir -p $(PKG_TARGET_DIR)/etc/cron.d
	cp -aL updater.conf $(PKG_TARGET_DIR)/etc
	cp -aL updater $(PKG_TARGET_DIR)/etc/cron.d
	cp -aL updater.sh $(PKG_TARGET_DIR)/sbin
	cp -aL ipkg $(PKG_TARGET_DIR)/usr/sbin
	cp -aL ipkg.move $(PKG_TARGET_DIR)/usr/sbin
	cp -a $(PKG_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	rm -rf $(PKG_TARGET_DIR)

srcclean: clean
	rm -rf $(PKG_DIR)
