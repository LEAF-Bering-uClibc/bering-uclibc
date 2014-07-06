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
ifdef BT_PLATFORM_EDITOR
	[ -f "busybox.config-$(BT_PLATFORM_EDITOR).patch" ] && \
	patch -d "$(BUSYBOX_DIR)" < "busybox.config-$(BT_PLATFORM_EDITOR).patch"
endif
	touch $(BUSYBOX_DIR)/.source

$(BUSYBOX_DIR)/.build: $(BUSYBOX_DIR)/.source
	mkdir -p $(BT_STAGING_DIR)/bin
	make $(MAKEOPTS) -C $(BUSYBOX_DIR) busybox
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BUSYBOX_DIR)/busybox
	cp -a $(BUSYBOX_DIR)/busybox $(BT_STAGING_DIR)/bin/
	touch $(BUSYBOX_DIR)/.build

source: $(BUSYBOX_DIR)/.source

build: $(BUSYBOX_DIR)/.build

clean:
	-rm $(BUSYBOX_DIR)/.build
	-make -C $(BUSYBOX_DIR) clean

srcclean: clean
	rm -rf $(BUSYBOX_DIR)
