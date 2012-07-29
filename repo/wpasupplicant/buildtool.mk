# makefile for wpasupplicant
include $(MASTERMAKEFILE)

SOURCE_DIR:=$(shell basename `tar tzf $(SOURCE_TARBALL) | head -1`)/wpa_supplicant
TARGET_DIR:=$(BT_BUILD_DIR)/wpasupplicant


.source:
	zcat $(SOURCE_TARBALL) | tar -xvf -
	touch .source

source: .source

.build:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/sbin
	mkdir -p $(TARGET_DIR)/etc
	mkdir -p $(TARGET_DIR)/etc/default
	mkdir -p $(TARGET_DIR)/etc/init.d
	cp -aL .config $(SOURCE_DIR)/.config
	make $(MAKEOPTS) CC=$(TARGET_CC) -C $(SOURCE_DIR)
	cp -a $(SOURCE_DIR)/wpa_cli $(TARGET_DIR)/usr/sbin
	cp -a $(SOURCE_DIR)/wpa_passphrase $(TARGET_DIR)/usr/sbin
	cp -a $(SOURCE_DIR)/wpa_supplicant $(TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	cp -aL wpa_supplicant.conf $(TARGET_DIR)/etc
	cp -aL wpasupplicant.default $(TARGET_DIR)/etc/default/wpasupplicant
	cp -aL wpasupplicant.init $(TARGET_DIR)/etc/init.d/wpasupplicant
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	make -C $(SOURCE_DIR) clean
	rm -rf $(TARGET_DIR)
	rm -f .build

srcclean: clean
	rm -rf $(SOURCE_DIR)
	rm -f .source
	rm -f .configured
