# makefile

PKG_DIR=.
PKG_TARGET_DIR:=$(BT_BUILD_DIR)/backup

source:

build:
	mkdir -p $(PKG_TARGET_DIR)
	mkdir -p $(PKG_TARGET_DIR)/sbin
	mkdir -p $(PKG_TARGET_DIR)/etc
	mkdir -p $(PKG_TARGET_DIR)/etc/cron.weekly
	cp -aL backup.conf $(PKG_TARGET_DIR)/etc
	cp -aL backup $(PKG_TARGET_DIR)/etc/cron.weekly
	cp -aL backup.sh $(PKG_TARGET_DIR)/sbin
	cp -a $(PKG_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	rm -rf $(PKG_TARGET_DIR)

srcclean: clean
	rm -rf $(PKG_DIR)
