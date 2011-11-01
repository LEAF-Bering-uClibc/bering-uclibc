#############################################################
#
# syslinux 
#
#############################################################

include $(MASTERMAKEFILE)
SYSLINUX_DIR:=syslinux-4.03
SYSLINUX_TARGET_DIR:=$(BT_BUILD_DIR)/syslinux


$(SYSLINUX_DIR)/.source: 
	bzcat $(SYSLINUX_SOURCE) |  tar -xvf - 
#	cat $(SYSLINUX_PATCH) | patch -d $(SYSLINUX_DIR) -p1
	touch $(SYSLINUX_DIR)/.source
	
$(SYSLINUX_DIR)/.build: $(SYSLINUX_DIR)/.source
	mkdir -p $(SYSLINUX_TARGET_DIR)/usr/bin
	mkdir -p $(SYSLINUX_TARGET_DIR)/usr/share/syslinux
	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) -C $(SYSLINUX_DIR) installer
	cp -a $(SYSLINUX_DIR)/core/pxelinux.0 $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/core/isolinux.bin $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/gpxe/gpxelinux.0 $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/mtools/syslinux $(SYSLINUX_TARGET_DIR)/usr/bin/
	cp -a $(SYSLINUX_DIR)/mbr/mbr.bin $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SYSLINUX_TARGET_DIR)/usr/bin/*
	cp -a $(SYSLINUX_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SYSLINUX_DIR)/.build

source: $(SYSLINUX_DIR)/.source

build: $(SYSLINUX_DIR)/.build

clean: 
	-rm $(SYSLINUX_DIR)/.build
	rm -rf $(SYSLINUX_TARGET_DIR)
	$(MAKE) -C $(SYSLINUX_DIR) clean

srcclean:
	rm -rf $(SYSLINUX_DIR)
