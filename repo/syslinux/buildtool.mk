#############################################################
# makefile for syslinux
#############################################################

SYSLINUX_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SYSLINUX_SOURCE) 2>/dev/null )
SYSLINUX_TARGET_DIR:=$(BT_BUILD_DIR)/syslinux

$(SYSLINUX_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SYSLINUX_SOURCE)
	cat $(SYSLINUX_PATCH1) | patch -d $(SYSLINUX_DIR) -p1 
#	sed -i 's:INCLUDES = -I. -I.. -I../libinstaller:INCLUDES = -I. -I.. -I../libinstaller -I$(BT_STAGING_DIR)/usr/include :' $(SYSLINUX_DIR)/extlinux/Makefile 
	touch $(SYSLINUX_DIR)/.source

$(SYSLINUX_DIR)/.build: $(SYSLINUX_DIR)/.source
	mkdir -p $(SYSLINUX_TARGET_DIR)/usr/bin
	mkdir -p $(SYSLINUX_TARGET_DIR)/usr/share/syslinux
	mkdir -p $(SYSLINUX_TARGET_DIR)/com32
	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) -C $(SYSLINUX_DIR) installer
	cp -a $(SYSLINUX_DIR)/core/pxelinux.0 $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/core/isolinux.bin $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/gpxe/gpxelinux.0 $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/mtools/syslinux $(SYSLINUX_TARGET_DIR)/usr/bin/
	cp -a $(SYSLINUX_DIR)/mbr/mbr.bin $(SYSLINUX_TARGET_DIR)/usr/share/syslinux/
	cp -a $(SYSLINUX_DIR)/com32/menu/vesamenu.c32 $(SYSLINUX_TARGET_DIR)/com32
	cp -a $(SYSLINUX_DIR)/com32/menu/menu.c32 $(SYSLINUX_TARGET_DIR)/com32
	cp -a $(SYSLINUX_DIR)/com32/hdt/hdt.c32 $(SYSLINUX_TARGET_DIR)/com32
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
