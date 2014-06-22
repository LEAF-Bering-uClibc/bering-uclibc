############################################
# makefile for udpxy
###########################################

UDPXY_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(UDPXY_SOURCE) 2>/dev/null)
UDPXY_TARGET_DIR:=$(BT_BUILD_DIR)/udpxy

$(UDPXY_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(UDPXY_SOURCE)
	touch $(UDPXY_DIR)/.source

source: $(UDPXY_DIR)/.source

$(UDPXY_DIR)/.build: $(UDPXY_DIR)/.source
	mkdir -p $(UDPXY_TARGET_DIR)
	mkdir -p $(UDPXY_TARGET_DIR)/usr/bin
	mkdir -p $(UDPXY_TARGET_DIR)/etc/init.d

# add lean target?
	make $(MAKEOPTS) -C $(UDPXY_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) release
	cp -aL udpxy.init $(UDPXY_TARGET_DIR)/etc/init.d/udpxy
	cp -a $(UDPXY_DIR)/udpxy $(UDPXY_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(UDPXY_TARGET_DIR)/usr/bin/*
	cp -a $(UDPXY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(UDPXY_DIR)/.build

build: $(UDPXY_DIR)/.build

clean:
	make -C $(UDPXY_DIR) clean
	rm -rf $(UDPXY_TARGET_DIR)
	rm -rf $(UDPXY_DIR)/.build
	rm -rf $(UDPXY_DIR)/.configured

srcclean: clean
	rm -rf $(UDPXY_DIR)
