XL2TPD_DIR:=xl2tpd-1.1.06

$(XL2TPD_DIR)/.source:
	zcat $(XL2TPD_SOURCE) |  tar -xvf -
	zcat $(XL2TPD_PATCH1) | patch -d $(XL2TPD_DIR) -p1
	cat $(XL2TPD_PATCH2) | patch -d $(XL2TPD_DIR) -p1
	touch $(XL2TPD_DIR)/.source

source: $(XL2TPD_DIR)/.source

$(XL2TPD_DIR)/.build:
	$(MAKE) $(MAKEOPTS) -C $(XL2TPD_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) DFLAGS="-DUSE_KERNEL"
	mkdir -p $(BT_STAGING_DIR)/etc/xl2tpd
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/etc/ppp
	cp $(XL2TPD_DIR)/xl2tpd $(BT_STAGING_DIR)/usr/sbin/
	cp $(XL2TPD_SAFE) $(BT_STAGING_DIR)/usr/sbin/
	cp $(XL2TPD_INITD) $(BT_STAGING_DIR)/etc/init.d/xl2tpd
	cp $(XL2TPD_DIR)/examples/ppp-options.xl2tpd $(BT_STAGING_DIR)/etc/ppp/options.l2tpd
	cp $(XL2TPD_DIR)/examples/xl2tpd.conf $(BT_STAGING_DIR)/etc/xl2tpd/xl2tpd.conf
	cp $(XL2TPD_DIR)/doc/l2tp-secrets.sample $(BT_STAGING_DIR)/etc/xl2tpd/l2tp-secrets
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BT_STAGING_DIR)/usr/sbin/xl2tpd
	touch $(XL2TPD_DIR)/.build

build: $(XL2TPD_DIR)/.build

clean:
	$(MAKE) -C $(XL2TPD_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/sbin/xl2tpd
	rm -f $(BT_STAGING_DIR)/usr/sbin/safe_xl2tpd
	rm -f $(BT_STAGING_DIR)/etc/xl2tpd/xl2tpd.conf
	rm -f $(BT_STAGING_DIR)/etc/xl2tpd/l2tp-secrets
	rm -f $(BT_STAGING_DIR)/etc/init.d/xl2tpd
	rm -f $(BT_STAGING_DIR)/etc/ppp/options.xl2tpd
	-rmdir $(BT_STAGING_DIR)/etc/init.d
	-rmdir $(BT_STAGING_DIR)/etc/xl2tpd
	-rmdir $(BT_STAGING_DIR)/etc/ppp
	rm -f $(XL2TPD_DIR)/.build

srcclean: clean
	rm -rf $(XL2TPD_DIR)
