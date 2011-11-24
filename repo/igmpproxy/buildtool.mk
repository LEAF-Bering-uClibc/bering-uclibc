# makefile for igmproxy
include $(MASTERMAKEFILE)

IGMPPROXY_DIR:=igmpproxy-0.1
IGMPPROXY_TARGET_DIR:=$(BT_BUILD_DIR)/igmpproxy

$(IGMPPROXY_DIR)/.source:
	zcat $(IGMPPROXY_SOURCE) | tar -xvf -
	touch $(IGMPPROXY_DIR)/.source

source: $(IGMPPROXY_DIR)/.source

$(IGMPPROXY_DIR)/.configured: $(IGMPPROXY_DIR)/.source
	(cd $(IGMPPROXY_DIR) ; \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--prefix=/usr )
	touch $(IGMPPROXY_DIR)/.configured

$(IGMPPROXY_DIR)/.build: $(IGMPPROXY_DIR)/.configured
	mkdir -p $(IGMPPROXY_TARGET_DIR)
	mkdir -p $(IGMPPROXY_TARGET_DIR)/etc
	mkdir -p $(IGMPPROXY_TARGET_DIR)/etc/init.d
	mkdir -p $(IGMPPROXY_TARGET_DIR)/usr/sbin

	$(MAKE) $(MAKEOPTS) -C $(IGMPPROXY_DIR)
	cp -a $(IGMPPROXY_DIR)/src/igmpproxy $(IGMPPROXY_TARGET_DIR)/usr/sbin
	cp -a $(IGMPPROXY_DIR)/igmpproxy.conf $(IGMPPROXY_TARGET_DIR)/etc
	cp -aL igmpproxy.init $(IGMPPROXY_TARGET_DIR)/etc/init.d/igmpproxy
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IGMPPROXY_TARGET_DIR)/usr/sbin/*
	cp -a $(IGMPPROXY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IGMPPROXY_DIR)/.build

build: $(IGMPPROXY_DIR)/.build

clean:
	make -C $(IGMPPROXY_DIR) clean
	rm -rf $(IGMPPROXY_TARGET_DIR)
	rm $(IGMPPROXY_DIR)/.build
	rm $(IGMPPROXY_DIR)/.configured

srcclean: clean
	rm -rf $(IGMPPROXY_DIR)
