include $(MASTERMAKEFILE)
PATCH_DIR:=patch-2.5.9
PATCH_TARGET_DIR:=$(BT_BUILD_DIR)/patch

$(PATCH_DIR)/.source:
	zcat $(PATCH_SOURCE) |  tar -xvf -
	touch $(PATCH_DIR)/.source

$(PATCH_DIR)/.configured: $(PATCH_DIR)/.source
	(cd $(PATCH_DIR); \
	./configure --prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	touch $(PATCH_DIR)/.configured

$(PATCH_DIR)/.build: $(PATCH_DIR)/.configured
	mkdir -p $(PATCH_TARGET_DIR)/usr/bin
	$(MAKE) $(MAKEOPTS) -C $(PATCH_DIR)
	cp -a $(PATCH_DIR)/patch $(PATCH_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PATCH_TARGET_DIR)/usr/bin/*
	cp -a $(PATCH_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(PATCH_DIR)/.build

source: $(PATCH_DIR)/.source

build: $(PATCH_DIR)/.build

clean:
	$(MAKE) -C $(PATCH_DIR) clean
	-rm -rf $(PATCH_TARGET_DIR)
	-rm $(BT_STAGING_DIR)/usr/sbin/patch
	-rm $(PATCH_DIR)/.build
	-rm $(PATCH_DIR)/.configured

srcclean:
	rm -rf $(PATCH_DIR)
