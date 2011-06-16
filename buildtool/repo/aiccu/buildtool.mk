# makefile for aiccu, adapted from bash
include $(MASTERMAKEFILE)

AICCU_DIR:=aiccu
AICCU_TARGET_DIR:=$(BT_BUILD_DIR)/aiccu

$(AICCU_DIR)/.source:
	zcat $(SRC_TARBALL) | tar -xvf -
	(cd $(AICCU_DIR) && patch -p1) < $(PATCH_UCLIBC_RESOLVER)
	(cd $(AICCU_DIR) && patch -p1) < $(PATCH_OPENWRT_100)
	(cd $(AICCU_DIR) && patch -p1) < $(PATCH_OPENWRT_200)
	(cd $(AICCU_DIR) && patch -p1) < $(PATCH_MAKEFILE)
	touch $(AICCU_DIR)/.source

source: $(AICCU_DIR)/.source

$(AICCU_DIR)/.configured: $(AICCU_DIR)/.source
	touch $(AICCU_DIR)/.configured

$(AICCU_DIR)/.build: $(AICCU_DIR)/.configured
	CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" make -C $(AICCU_DIR) all
	mkdir -p "$(AICCU_TARGET_DIR)"
	cd "$(AICCU_TARGET_DIR)" && mkdir -p usr/sbin etc etc/init.d
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(AICCU_DIR)/unix-console/aiccu
	cp -a $(AICCU_DIR)/unix-console/aiccu $(AICCU_TARGET_DIR)/usr/sbin
	cp -a $(AICCU_DIR)/doc/aiccu.conf     $(AICCU_TARGET_DIR)/etc
	cp -aL aiccu.init $(AICCU_TARGET_DIR)/etc/init.d/aiccu
	cp -a $(AICCU_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $@

build: $(AICCU_DIR)/.build

clean:
	make -C $(AICCU_DIR) clean
	rm -rf $(AICCU_TARGET_DIR)
	rm -f $(AICCU_DIR)/.build
	rm -f $(AICCU_DIR)/.configured

srcclean: clean
	rm -rf $(AICCU_DIR) 
	rm -f $(AICCU_DIR)/.source
