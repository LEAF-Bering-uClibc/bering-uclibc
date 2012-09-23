# makefile for privoxy

PRIVOXY_DIR:=privoxy-3.0.19-stable
PRIVOXY_TARGET_DIR:=$(BT_BUILD_DIR)/privoxy


$(PRIVOXY_DIR)/.source:
	zcat $(PRIVOXY_SOURCE) | tar -xvf -
	touch $(PRIVOXY_DIR)/.source

source: $(PRIVOXY_DIR)/.source

$(PRIVOXY_DIR)/.configured: $(PRIVOXY_DIR)/.source
	(cd $(PRIVOXY_DIR) ; autoreconf -i -f; \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-dynamic-pcre );
	touch $(PRIVOXY_DIR)/.configured

$(PRIVOXY_DIR)/.build: $(PRIVOXY_DIR)/.configured
	mkdir -p $(PRIVOXY_TARGET_DIR)
	mkdir -p $(PRIVOXY_TARGET_DIR)/etc/init.d
	mkdir -p $(PRIVOXY_TARGET_DIR)/usr/sbin
	mkdir -p $(PRIVOXY_TARGET_DIR)/etc/privoxy
	mkdir -p $(PRIVOXY_TARGET_DIR)/etc/privoxy/templates
	make $(MAKEOPTS) -C $(PRIVOXY_DIR)

	cp -aL privoxy.init $(PRIVOXY_TARGET_DIR)/etc/init.d/privoxy
	cp -aL privoxy.config $(PRIVOXY_TARGET_DIR)/etc/privoxy/config
	cp -a $(PRIVOXY_DIR)/default.action $(PRIVOXY_TARGET_DIR)/etc/privoxy
	cp -a $(PRIVOXY_DIR)/default.filter $(PRIVOXY_TARGET_DIR)/etc/privoxy
	cp -a $(PRIVOXY_DIR)/match-all.action $(PRIVOXY_TARGET_DIR)/etc/privoxy
	cp -a $(PRIVOXY_DIR)/privoxy $(PRIVOXY_TARGET_DIR)/usr/sbin
	cp -a $(PRIVOXY_DIR)/templates/* $(PRIVOXY_TARGET_DIR)/etc/privoxy/templates
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PRIVOXY_TARGET_DIR)/usr/sbin/*
	cp -a $(PRIVOXY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PRIVOXY_DIR)/.build

build: $(PRIVOXY_DIR)/.build

clean:
	make -C $(PRIVOXY_DIR) clean
	rm -rf $(PRIVOXY_TARGET_DIR)
	rm -rf $(PRIVOXY_DIR)/.build
	rm -rf $(PRIVOXY_DIR)/.configured

srcclean: clean
	rm -rf $(PRIVOXY_DIR)
	rm -rf $(PRIVOXY_DIR)/.source
