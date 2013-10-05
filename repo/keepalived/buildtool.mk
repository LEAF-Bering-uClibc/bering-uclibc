#############################################################
#
# keepalived
#
#############################################################


KEEPALIVED_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(KEEPALIVED_SOURCE) 2>/dev/null )
KEEPALIVED_TARGET_DIR:=$(BT_BUILD_DIR)/keepalived


$(KEEPALIVED_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(KEEPALIVED_SOURCE)
	cat $(INCLUDES_PATCH) | patch -p1 -d $(KEEPALIVED_DIR)
	touch $(KEEPALIVED_DIR)/.source

$(KEEPALIVED_DIR)/.configured: $(KEEPALIVED_DIR)/.source
	(cd $(KEEPALIVED_DIR); rm -rf config.cache; autoreconf -i -f; \
		./configure \
		--prefix=/usr \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME) \
		--with-kernel-dir=$(BT_LINUX_DIR) \
		 );
		touch $(KEEPALIVED_DIR)/.configured

$(KEEPALIVED_DIR)/.build: $(KEEPALIVED_DIR)/.configured
	make $(MAKEOPTS) -C $(KEEPALIVED_DIR) all
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/etc/keepalived
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/etc/init.d
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/usr/bin
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/usr/sbin
	cp -aL keepalived.init $(KEEPALIVED_TARGET_DIR)/etc/init.d/keepalived
	cp -aL keepalived.conf $(KEEPALIVED_TARGET_DIR)/etc/keepalived/keepalived.conf
	cp -f $(KEEPALIVED_DIR)/bin/genhash $(KEEPALIVED_TARGET_DIR)/usr/bin/
	cp -f $(KEEPALIVED_DIR)/bin/keepalived $(KEEPALIVED_TARGET_DIR)/usr/sbin/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(KEEPALIVED_TARGET_DIR)/usr/bin/*
	cp -a -f $(KEEPALIVED_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(KEEPALIVED_DIR)/.build

source: $(KEEPALIVED_DIR)/.source

build: $(KEEPALIVED_DIR)/.build

clean:
	-rm -f $(KEEPALIVED_DIR)/.build
	-rm -f $(KEEPALIVED_DIR)/.configured
	-make -C $(KEEPALIVED_DIR) clean
	-rm -rf $(KEEPALIVED_TARGET_DIR)

srcclean:
	-rm -rf $(KEEPALIVED_DIR)
