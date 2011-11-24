# makefile for freenet6
include $(MASTERMAKEFILE)

FREENET6_DIR:=freenet6-client-1.0
FREENET6_TARGET_DIR:=$(BT_BUILD_DIR)/freenet6

$(FREENET6_DIR)/.source:
	zcat $(FREENET6_SOURCE) | tar -xvf -
	cat $(FREENET6_PATCH1) | patch -d $(FREENET6_DIR) -p1
	touch $(FREENET6_DIR)/.source

source: $(FREENET6_DIR)/.source

$(FREENET6_DIR)/.configured: $(FREENET6_DIR)/.source
	touch $(FREENET6_DIR)/.configured

$(FREENET6_DIR)/.build: $(FREENET6_DIR)/.configured
	mkdir -p $(FREENET6_TARGET_DIR)
	mkdir -p $(FREENET6_TARGET_DIR)/etc/ppp/ip-up.d
	mkdir -p $(FREENET6_TARGET_DIR)/etc/ppp/ip-down.d
	mkdir -p $(FREENET6_TARGET_DIR)/etc/freenet6
	mkdir -p $(FREENET6_TARGET_DIR)/etc/init.d
	mkdir -p $(FREENET6_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) CC=$(TARGET_CC) DEFINES="$(CFLAGS)" -C $(FREENET6_DIR) all target=linux
	cp -aL setup.sh $(FREENET6_TARGET_DIR)/etc/freenet6
	cp -aL tspc.conf $(FREENET6_TARGET_DIR)/etc/freenet6
	cp -aL freenet6.init $(FREENET6_TARGET_DIR)/etc/init.d/freenet6
	cp -aL 0freenet6.up $(FREENET6_TARGET_DIR)/etc/ppp/ip-up.d/0freenet6
	cp -aL 0freenet6.down $(FREENET6_TARGET_DIR)/etc/ppp/ip-down.d/0freenet6
	cp -a $(FREENET6_DIR)/template/checktunnel.sh $(FREENET6_TARGET_DIR)/etc/freenet6
	cp -a $(FREENET6_DIR)/bin/tspc $(FREENET6_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(FREENET6_TARGET_DIR)/usr/sbin/*
	cp -a $(FREENET6_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(FREENET6_DIR)/.build

build: $(FREENET6_DIR)/.build

clean:
	make -C $(FREENET6_DIR) clean target=linux
	rm -rf $(FREENET6_TARGET_DIR)
	rm -rf $(FREENET6_TARGET_DIR)/bin/*
	rm -rf $(FREENET6_DIR)/.build
	rm -rf $(FREENET6_DIR)/.configured

srcclean: clean
	rm -rf $(FREENET6_DIR)
	rm -rf $(FREENET6_DIR)/.source
