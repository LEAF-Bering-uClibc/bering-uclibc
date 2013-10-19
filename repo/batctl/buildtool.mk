############################################
# makefile for batctl
###########################################

BATCTL_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(BATCTL_SOURCE) 2>/dev/null)
BATCTL_TARGET_DIR:=$(BT_BUILD_DIR)/batctl

$(BATCTL_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(BATCTL_SOURCE)
	touch $(BATCTL_DIR)/.source

source: $(BATCTL_DIR)/.source

$(BATCTL_DIR)/.build: $(BATCTL_DIR)/.source
	mkdir -p $(BATCTL_TARGET_DIR)
	mkdir -p $(BATCTL_TARGET_DIR)/usr/bin
#	mkdir -p $(BATCTL_TARGET_DIR)/etc/init.d

	make $(MAKEOPTS) -C $(BATCTL_DIR) DESTDIR=$(BATCTL_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS)" all

	cp -a $(BATCTL_DIR)/batctl $(BATCTL_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BATCTL_TARGET_DIR)/usr/bin/*
	cp -a $(BATCTL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(BATCTL_DIR)/.build

build: $(BATCTL_DIR)/.build

clean:
	make -C $(BATCTL_DIR) clean
	rm -rf $(BATCTL_TARGET_DIR)
	rm -rf $(BATCTL_DIR)/.build
	rm -rf $(BATCTL_DIR)/.configured

srcclean: clean
	rm -rf $(BATCTL_DIR)
