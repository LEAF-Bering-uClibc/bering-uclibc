# makefile for igb

DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/igb
MODULE_PATH=kernel/drivers/net/ethernet/intel/igb
EXTRA_VARS=$(MAKEOPTS)

$(DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SOURCE)
	cat $(PATCH1) | patch -p1 -d $(DIR)
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.build:
	(cd $(DIR)/src && for i in $(KARCHS_PCIE); do \
	$(MAKE) $(EXTRA_VARS) KSRC=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) && \
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) igb.ko && gzip -9 -f igb.ko && \
	mkdir -p $(TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/$(MODULE_PATH) && \
	cp -a igb.ko.gz $(TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/$(MODULE_PATH) ||\
	exit 1 ; done)
	-cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	rm -rf $(TARGET_DIR)
	(cd $(DIR)/src && for i in $(KARCHS_PCIE); do \
		$(MAKE) $(EXTRA_VARS) KSRC=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) clean ; done)
	rm -f $(DIR)/.build

srcclean: clean
	rm -rf $(DIR)
	rm -f $(DIR)/.source
