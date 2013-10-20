#############################################################
#
# dosfstools
#
#############################################################

DOSFSTOOLS_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(DOSFSTOOLS_SOURCE) 2>/dev/null)
DOSFSTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/dosfstools
export CC=$(TARGET_CC)

$(DOSFSTOOLS_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(DOSFSTOOLS_SOURCE)
	touch $(DOSFSTOOLS_DIR)/.source

$(DOSFSTOOLS_DIR)/.build: $(DOSFSTOOLS_DIR)/.source
	mkdir -p $(DOSFSTOOLS_TARGET_DIR)
	export PREFIX=$(DOSFSTOOLS_TARGET_DIR)
	$(MAKE) $(MAKEOPTS)  LDFLAGS="-liconv $(LDFLAGS)" -C $(DOSFSTOOLS_DIR)
	$(MAKE) -C $(DOSFSTOOLS_DIR) install DESTDIR=$(DOSFSTOOLS_TARGET_DIR) PREFIX=/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DOSFSTOOLS_TARGET_DIR)/sbin/*
	-rm -rf $(DOSFSTOOLS_TARGET_DIR)/share
	cp -a $(DOSFSTOOLS_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DOSFSTOOLS_DIR)/.build

source: $(DOSFSTOOLS_DIR)/.source

build: $(DOSFSTOOLS_DIR)/.build

clean:
	rm -rf $(DOSFSTOOLS_TARGET_DIR)
	-rm $(DOSFSTOOLS_DIR)/.build
	$(MAKE) -C $(DOSFSTOOLS_DIR) clean

srcclean:
	rm -rf $(DOSFSTOOLS_DIR)
