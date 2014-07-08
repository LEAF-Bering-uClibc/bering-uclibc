#############################################################
#
# busybox
#
#############################################################
BUSYBOX_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(BUSYBOX_SOURCE) 2>/dev/null )

$(BUSYBOX_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(BUSYBOX_SOURCE)
	cat $(BUSYBOX_PATCH1) | patch -d $(BUSYBOX_DIR) -p1
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_DIR)/.config
	touch $(BUSYBOX_DIR)/.source

$(BUSYBOX_DIR)/.build: $(BUSYBOX_DIR)/.source
	mkdir -p $(BT_STAGING_DIR)/bin
	$(MAKE) $(MAKEOPTS) -C $(BUSYBOX_DIR) busybox
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BUSYBOX_DIR)/busybox
	cp -a $(BUSYBOX_DIR)/busybox $(BT_STAGING_DIR)/bin/
	touch $(BUSYBOX_DIR)/.build

source: $(BUSYBOX_DIR)/.source

build: $(BUSYBOX_DIR)/.build

clean:
	make -C $(BUSYBOX_DIR) clean
	-rm $(BUSYBOX_DIR)/.build

srcclean: clean
	rm -rf $(BUSYBOX_DIR)
