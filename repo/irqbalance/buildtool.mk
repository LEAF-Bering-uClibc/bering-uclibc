# makefile for irqbalance

DIR:=irqbalance-0.55
TARGET_DIR:=$(BT_BUILD_DIR)/irqbalance
PERLVER:=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	zcat $(PATCH1) | patch -p1 -d $(DIR)
	touch $(DIR)/.source

$(DIR)/.build:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/sbin
	mkdir -p $(TARGET_DIR)/etc/init.d
	make -C $(DIR) CC=$(TARGET_CC)
	cp -a $(DIR)/irqbalance $(TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	cp -aL irqbalance.init $(TARGET_DIR)/etc/init.d/irqbalance
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

source: $(DIR)/.source

build: $(DIR)/.build

clean: unpatch
	make -C $(DIR) distclean
	rm -rf $(TARGET_DIR)

srcclean: clean
	rm -rf $(DIR)
