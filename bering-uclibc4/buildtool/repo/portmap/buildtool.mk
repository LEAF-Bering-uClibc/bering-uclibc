#############################################################
#
# buildtool makefile for portmap
#
#############################################################

include $(MASTERMAKEFILE)

PORTMAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(PORTMAP_SOURCE) 2>/dev/null )
ifeq ($(PORTMAP_DIR),)
PORTMAP_DIR:=$(shell cat DIRNAME)
endif
PORTMAP_TARGET_DIR:=$(BT_BUILD_DIR)/portmap

$(PORTMAP_DIR)/.source:
	zcat $(PORTMAP_SOURCE) | tar -xvf -
# omit "-o root -g root" arguments from "install", so can run "make install"
# without being "root"; will get corrected as part of LRP installation
	( cd $(PORTMAP_DIR) ; sed -i -e "/-o root -g root /s///" Makefile )
	echo $(PORTMAP_DIR) > DIRNAME
	touch $(PORTMAP_DIR)/.source

source: $(PORTMAP_DIR)/.source

build: source
	mkdir -p $(PORTMAP_TARGET_DIR)/sbin
	mkdir -p $(PORTMAP_TARGET_DIR)/usr/share/man/man8
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(PORTMAP_DIR)
	$(MAKE) -C $(PORTMAP_DIR) BASEDIR=$(PORTMAP_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PORTMAP_TARGET_DIR)/sbin/portmap
	cp -f $(PORTMAP_TARGET_DIR)/sbin/portmap $(BT_STAGING_DIR)/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PORTMAP_TARGET_DIR)/sbin/pmap_set
	cp -f $(PORTMAP_TARGET_DIR)/sbin/pmap_set $(BT_STAGING_DIR)/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PORTMAP_TARGET_DIR)/sbin/pmap_dump
	cp -f $(PORTMAP_TARGET_DIR)/sbin/pmap_dump $(BT_STAGING_DIR)/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/default/
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	cp -aL portmap.default $(BT_STAGING_DIR)/etc/default/portmap
	cp -aL portmap.init $(BT_STAGING_DIR)/etc/init.d/portmap

clean:
	rm -rf $(PORTMAP_TARGET_DIR)
	$(MAKE) -C $(PORTMAP_DIR) clean

srcclean: clean
	rm -rf $(PORTMAP_DIR)
	-rm DIRNAME

