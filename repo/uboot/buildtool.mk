# makefile for uboot

UBOOT_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(UBOOT_SOURCE) 2>/dev/null )
UBOOT_TARGET_DIR:=$(BT_BUILD_DIR)/uboot

.source:
	$(BT_SETUP_BUILDDIR) -v $(UBOOT_SOURCE)
	touch .source

source: .source


$(UBOOT_DIR)/.build: .source
	mkdir -p $(UBOOT_TARGET_DIR)
	export ARCH=$(UBOOT_ARCH); cd $(UBOOT_DIR); make CROSS_COMPILE="$(CROSS_COMPILE)" $(UBOOT_BOARDTYPE)
#	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(UBOOT_TARGET_DIR)/usr/bin/*
#	cp -a $(UBOOT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(UBOOT_DIR)/.build

build: $(UBOOT_DIR)/.build

clean:
	make -C $(UBOOT_DIR) clean
	rm -rf $(UBOOT_TARGET_DIR)
	rm -f $(UBOOT_DIR)/.build
	rm -f $(UBOOT_DIR)/.configured

srcclean: clean
	rm -rf $(UBOOT_DIR)
	rm -f .source
