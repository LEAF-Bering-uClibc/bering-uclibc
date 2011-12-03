# makefile for tinyproxy
include $(MASTERMAKEFILE)

TINYPROXY_DIR:=tinyproxy-1.8.3
TINYPROXY_TARGET_DIR:=$(BT_BUILD_DIR)/tinyproxy
export tinyproxy_cv_regex_broken=no

$(TINYPROXY_DIR)/.source:
	bzcat $(TINYPROXY_SOURCE) | tar -xvf -
	cat $(TINYPROXY_PATCH) | patch -p1 -d $(TINYPROXY_DIR)
	touch $(TINYPROXY_DIR)/.source

source: $(TINYPROXY_DIR)/.source

$(TINYPROXY_DIR)/.configured: $(TINYPROXY_DIR)/.source
	(cd $(TINYPROXY_DIR) ; ./autogen.sh \
	--prefix=/usr --host=$(GNU_TARGET_NAME) \
	--sysconfdir=/etc/tinyproxy --enable-xtinyproxy \
	--bindir=/usr/sbin --enable-transparent-proxy )
	touch $(TINYPROXY_DIR)/.configured

$(TINYPROXY_DIR)/.build: $(TINYPROXY_DIR)/.configured
	mkdir -p $(TINYPROXY_TARGET_DIR)
	mkdir -p $(TINYPROXY_TARGET_DIR)/etc/tinyproxy
	mkdir -p $(TINYPROXY_TARGET_DIR)/etc/init.d
	mkdir -p $(TINYPROXY_TARGET_DIR)/etc/cron.daily
	mkdir -p $(TINYPROXY_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(TINYPROXY_DIR)/src all
	cp -aL tinyproxy.init $(TINYPROXY_TARGET_DIR)/etc/init.d/tinyproxy
	cp -aL tinyproxy.conf $(TINYPROXY_TARGET_DIR)/etc/tinyproxy/tinyproxy.conf
	cp -aL filter $(TINYPROXY_TARGET_DIR)/etc/tinyproxy/filter
	cp -aL tinyproxy.cron $(TINYPROXY_TARGET_DIR)/etc/cron.daily/tinyproxy
	cp -a $(TINYPROXY_DIR)/src/tinyproxy $(TINYPROXY_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TINYPROXY_TARGET_DIR)/usr/sbin/*
	cp -a $(TINYPROXY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TINYPROXY_DIR)/.build

build: $(TINYPROXY_DIR)/.build

clean:
#	make -C $(TINYPROXY_DIR) clean
	rm -rf $(TINYPROXY_TARGET_DIR)
	rm -rf $(TINYPROXY_DIR)/.build
	rm -rf $(TINYPROXY_DIR)/.configured

srcclean: clean
	rm -rf $(TINYPROXY_DIR)
