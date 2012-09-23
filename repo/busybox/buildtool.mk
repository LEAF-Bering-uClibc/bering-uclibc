#############################################################
#
# busybox
#
#############################################################


BUSYBOX_DIR=$(shell echo $(BUSYBOX_SOURCE) | sed 's/\.\(tar\.\|\t\)\(gz\|bz2\)//')
#BUSYBOX_BUILD_DIR=$(BT_BUILD_DIR)/busybox

#export PREFIX=$(BUSYBOX_BUILD_DIR)

$(BUSYBOX_DIR)/.source:
	bzcat $(BUSYBOX_SOURCE) | tar -xvf -
	cat $(BUSYBOX_PATCH1) | patch -d $(BUSYBOX_DIR) -p1
#	cat $(BUSYBOX_PATCH2) | patch -d $(BUSYBOX_DIR) -p1
#	cat $(BUSYBOX_PATCH3) | patch -d $(BUSYBOX_DIR) -p1
	touch $(BUSYBOX_DIR)/.source

$(BUSYBOX_DIR)/.build: $(BUSYBOX_DIR)/.source
#	mkdir -p $(BUSYBOX_BUILD_DIR)
#	mkdir -p $(BUSYBOX_BUILD_DIR)/etc/init.d
#	mkdir -p $(BUSYBOX_BUILD_DIR)/etc/default
	mkdir -p $(BT_STAGING_DIR)/bin
	cp .config $(BUSYBOX_DIR)/
	make $(MAKEOPTS) -C $(BUSYBOX_DIR) busybox
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BUSYBOX_DIR)/busybox
	cp -a $(BUSYBOX_DIR)/busybox $(BT_STAGING_DIR)/bin/
#	cp -a $(BUSYBOX_BUILD_DIR)/* $(BT_STAGING_DIR)/bin
#	cp -a $(BUSYBOX_BUILD_DIR)/etc/init.d/* $(BT_STAGING_DIR)/etc/init.d/
#	cp -a $(BUSYBOX_BUILD_DIR)/etc/default/* $(BT_STAGING_DIR)/etc/default/
	touch $(BUSYBOX_DIR)/.build

source: $(BUSYBOX_DIR)/.source

build: $(BUSYBOX_DIR)/.build

clean:
	-rm $(BUSYBOX_DIR)/.build
#	-rm -r $(BUSYBOX_BUILD_DIR)
	-make -C $(BUSYBOX_DIR) clean

srcclean:
	rm -rf $(BUSYBOX_DIR)
