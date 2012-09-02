#############################################################
#
# buildtool makefile for portmap
#
#############################################################

include $(MASTERMAKEFILE)

PORTMAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(PORTMAP_SOURCE) 2>/dev/null )
PORTMAP_TARGET_DIR:=$(BT_BUILD_DIR)/portmap

$(PORTMAP_DIR)/.source:
	zcat $(PORTMAP_SOURCE) | tar -xvf -
# omit "-o root -g root" arguments from "install", so can run "make install"
# without being "root"; will get corrected as part of LRP installation
	( cd $(PORTMAP_DIR) ; sed -i -e "/-o root -g root /s///" Makefile )
# specify use of target (rather than host) strip program for "install"
	( cd $(PORTMAP_DIR) ; sed -i -e "/-s /s//-s --strip-program=$(GNU_TARGET_NAME)-strip /" Makefile )
	perl -i -p -e 's,^.*\s0644\s.*share/man.*$$,,g' $(PORTMAP_DIR)/Makefile
	touch $(PORTMAP_DIR)/.source

source: $(PORTMAP_DIR)/.source

build: source
	mkdir -p $(PORTMAP_TARGET_DIR)/sbin
	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(PORTMAP_DIR)
	$(MAKE) -C $(PORTMAP_DIR) BASEDIR=$(PORTMAP_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PORTMAP_TARGET_DIR)/sbin/*
	mkdir -p $(BT_STAGING_DIR)/sbin
	cp -af $(PORTMAP_TARGET_DIR)/sbin/* $(BT_STAGING_DIR)/sbin/
	mkdir -p $(BT_STAGING_DIR)/etc/default/
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	cp -aL portmap.default $(BT_STAGING_DIR)/etc/default/portmap
	cp -aL portmap.init $(BT_STAGING_DIR)/etc/init.d/portmap

clean:
	rm -rf $(PORTMAP_TARGET_DIR)
	$(MAKE) -C $(PORTMAP_DIR) clean

srcclean: clean
	rm -rf $(PORTMAP_DIR)
