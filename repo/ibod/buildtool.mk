#############################################################
#
# ibod
#
#############################################################

IBOD_DIR:=ibod-1.5.0
IBOD_TARGET_DIR:=$(BT_BUILD_DIR)/ibod


$(IBOD_DIR)/.source:
	zcat $(IBOD_SOURCE) | tar -xvf -
	zcat $(IBOD_PATCH1) | patch -d $(IBOD_DIR) -p1
	touch $(IBOD_DIR)/.source

$(IBOD_DIR)/.build:
	mkdir -p $(IBOD_TARGET_DIR)
	mkdir -p $(IBOD_TARGET_DIR)/usr/bin
	mkdir -p $(IBOD_TARGET_DIR)/etc/isdn
	mkdir -p $(IBOD_TARGET_DIR)/etc/ppp/ip-up.d
	mkdir -p $(IBOD_TARGET_DIR)/etc/ppp/ip-down.d
	$(MAKE) -C $(IBOD_DIR) CC=$(TARGET_CC) CFLAGS="$(CFLAGS) $(LDFLAGS)" ibod
	cp -a $(IBOD_DIR)/ibod $(IBOD_TARGET_DIR)/usr/bin/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IBOD_TARGET_DIR)/usr/bin/*
	cp -aL ibod.cf $(IBOD_TARGET_DIR)/etc/isdn/
	cp -aL 00-ibod $(IBOD_TARGET_DIR)/etc/ppp/ip-up.d/
	cp -aL zz-ibod $(IBOD_TARGET_DIR)/etc/ppp/ip-down.d/
	cp -a $(IBOD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IBOD_DIR)/.build

source: $(IBOD_DIR)/.source

build: $(IBOD_DIR)/.build

clean:
	-rm $(IBOD_DIR)/.build
	$(MAKE) -C $(IBOD_DIR) clean

srcclean:
	rm -rf $(IBOD_DIR)
