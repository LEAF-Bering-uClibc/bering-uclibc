#############################################################
#
# busybox
#
# $Id: buildtool.mk,v 1.9 2011/01/02 22:50:57 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

BUSYBOX_DIR=busybox-1.18.2
BUSYBOX_BUILD_DIR=$(BT_BUILD_DIR)/busybox

BUSYBOX_CFLAGS="-Os"
export prefix=$(BUSYBOX_BUILD_DIR)

$(BUSYBOX_DIR)/.source: 
	bzcat $(BUSYBOX_SOURCE) | tar -xvf -
	cat $(BUSYBOX_PATCH1) | patch -d $(BUSYBOX_DIR) -p1
	cat $(BUSYBOX_PATCH2) | patch -d $(BUSYBOX_DIR) -p1
	cat $(BUSYBOX_PATCH3) | patch -d $(BUSYBOX_DIR) -p1
	touch $(BUSYBOX_DIR)/.source
	
$(BUSYBOX_DIR)/.build: $(BUSYBOX_DIR)/.source
	mkdir -p $(BUSYBOX_BUILD_DIR)
	mkdir -p $(BUSYBOX_BUILD_DIR)/etc/init.d
	mkdir -p $(BUSYBOX_BUILD_DIR)/etc/default
	-mkdir -p $(BT_STAGING_DIR)/etc/init.d
	-mkdir -p $(BT_STAGING_DIR)/etc/default
	
	cp .config $(BUSYBOX_DIR)/
#	make CROSS_COMPILER_PREFIX="$(BT_STAGING_DIR)/bin/i386-linux-"  -C $(BUSYBOX_DIR) dep
#	make CROSS_COMPILER_PREFIX="$(BT_STAGING_DIR)/bin/i386-linux-"  -C $(BUSYBOX_DIR) 
	make CC="$(TARGET_CC)" -C $(BUSYBOX_DIR) 
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BUSYBOX_DIR)/busybox
	cp -a $(BUSYBOX_DIR)/busybox $(BUSYBOX_BUILD_DIR)
	cp -a $(BUSYBOX_BUILD_DIR)/* $(BT_STAGING_DIR)/bin
#	cp -a $(BUSYBOX_BUILD_DIR)/etc/init.d/* $(BT_STAGING_DIR)/etc/init.d/
#	cp -a $(BUSYBOX_BUILD_DIR)/etc/default/* $(BT_STAGING_DIR)/etc/default/
	touch $(BUSYBOX_DIR)/.build

source: $(BUSYBOX_DIR)/.source

build: $(BUSYBOX_DIR)/.build

clean:  
	-rm $(BUSYBOX_DIR)/.build
	-rm -r $(BUSYBOX_BUILD_DIR)
	-make -C $(BUSYBOX_DIR) clean

srcclean:
	rm -rf $(BUSYBOX_DIR)	
