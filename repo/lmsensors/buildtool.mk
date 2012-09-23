#############################################################
#
# lmsensors
#
#############################################################


LMSENSORS_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LMSENSORS_SOURCE) 2>/dev/null )
LMSENSORS_TARGET_DIR:=$(BT_BUILD_DIR)/lmsensors

EXT_OPT := CC=$(TARGET_CC) DESTDIR=$(LMSENSORS_TARGET_DIR) PREFIX=/usr MACHINE=i686

$(LMSENSORS_DIR)/.source:
	bzcat $(LMSENSORS_SOURCE) | tar -xvf -
	touch $(LMSENSORS_DIR)/.source

source: $(LMSENSORS_DIR)/.source

$(LMSENSORS_DIR)/.build: source
	-mkdir $(LMSENSORS_TARGET_DIR)/
	-mkdir -p $(BT_STAGING_DIR)/usr/bin
	-mkdir -p $(BT_STAGING_DIR)/usr/sbin
	-mkdir -p $(BT_STAGING_DIR)/usr/lib
	-mkdir -p $(BT_STAGING_DIR)/usr/include
	-mkdir -p $(BT_STAGING_DIR)/etc/init.d
	$(MAKE) $(MAKEOPTS) $(EXT_OPT) -C $(LMSENSORS_DIR) user
	$(MAKE) $(MAKEOPTS) $(EXT_OPT) -C $(LMSENSORS_DIR) user_install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LMSENSORS_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LMSENSORS_TARGET_DIR)/usr/lib/*
	cp -aL lm-sensors.init $(BT_STAGING_DIR)/etc/init.d/lm-sensors
	cp -a $(LMSENSORS_TARGET_DIR)/usr/bin/sensors $(BT_STAGING_DIR)/usr/bin
	cp -a $(LMSENSORS_TARGET_DIR)/usr/sbin/sensors-detect $(BT_STAGING_DIR)/usr/sbin
	cp -a $(LMSENSORS_TARGET_DIR)/usr/lib/libsensors.* $(BT_STAGING_DIR)/usr/lib
	cp -a $(LMSENSORS_TARGET_DIR)/etc/sensors3.conf $(BT_STAGING_DIR)/etc
	cp -a $(LMSENSORS_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
	touch $(LMSENSORS_DIR)/.build

build: $(LMSENSORS_DIR)/.build

clean:
	$(MAKE) DESTDIR=$(LMSENSORS_TARGET_DIR) -C $(LMSENSORS_DIR) clean
	rm -f $(LMSENSORS_DIR)/.build

srcclean:
	rm -rf $(LMSENSORS_DIR)
	rm -rf $(LMSENSORS_TARGET_DIR)
