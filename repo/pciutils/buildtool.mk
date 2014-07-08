# makefile for pciutils

PCIUTILS_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(PCIUTILS_SOURCE) 2>/dev/null )
PCIUTILS_TARGET_DIR:=$(BT_BUILD_DIR)/pciutils

$(PCIUTILS_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(PCIUTILS_SOURCE)
	touch $(PCIUTILS_DIR)/.source

source: $(PCIUTILS_DIR)/.source

$(PCIUTILS_DIR)/.build: $(PCIUTILS_DIR)/.source
	mkdir -p $(PCIUTILS_TARGET_DIR)
	$(MAKE) -C $(PCIUTILS_DIR) HOST="$(GNU_TARGET_NAME)" CROSS_COMPILE="$(GNU_TARGET_NAME)-"  \
		OPT="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" PREFIX=/usr DESTDIR=$(PCIUTILS_TARGET_DIR) install
	rm -rf $(PCIUTILS_TARGET_DIR)/usr/share/man
	cp -aL $(PCI_IDS) $(PCIUTILS_TARGET_DIR)/usr/share/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PCIUTILS_TARGET_DIR)/usr/sbin/*
	cp -a -f $(PCIUTILS_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(PCIUTILS_DIR)/.build

build: $(PCIUTILS_DIR)/.build

clean:
	make -C $(PCIUTILS_DIR) clean
	rm -rf $(PCIUTILS_TARGET_DIR)
	-rm $(PCIUTILS_DIR)/.build

srcclean:
	rm -rf $(PCIUTILS_TARGET_DIR)
	rm -rf $(PCIUTILS_DIR)
