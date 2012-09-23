######################################
#
# buildtool make file for snort
#
######################################


SNORT_DIR:=snort-2.4.5
SNORT_TARGET_DIR:=$(BT_BUILD_DIR)/snort


CONFFLAGS:= --prefix=/usr --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-libpcap_includes=$(BT_STAGING_DIR)/usr/include/ \
	--with-libpcap_libraries=$(BT_STAGING_DIR)/usr/lib/ \
	--with-libpcre_includes=$(BT_STAGING_DIR)/usr/include/ \
	--with-libpcre_libraries=$(BT_STAGING_DIR)/usr/lib/ \
	--without-postgresql


$(SNORT_DIR)/.source:
	zcat $(SNORT_SOURCE) | tar -xvf -
	zcat $(SNORT_PATCH) | patch -d $(SNORT_DIR) -p1
	cd $(SNORT_DIR); zcat ../$(SNORT_RULES) | tar -xvf -
	zcat $(BT_TOOLS_DIR)/config.sub.gz >$(SNORT_DIR)/config.sub
	touch $(SNORT_DIR)/.source

source: $(SNORT_DIR)/.source


$(SNORT_DIR)/.build: $(SNORT_DIR)/.source
	mkdir -p $(SNORT_TARGET_DIR)
	mkdir -p $(SNORT_TARGET_DIR)/etc/snort/rules/
	mkdir -p $(SNORT_TARGET_DIR)/etc/init.d
	mkdir -p $(SNORT_TARGET_DIR)/etc/default
	mkdir -p $(SNORT_TARGET_DIR)/usr/bin/
	(cd $(SNORT_DIR) ; ./configure $(CONFFLAGS) --without-mysql )
	make $(MAKEOPTS) -C $(SNORT_DIR)
	cp -a -f $(SNORT_DIR)/src/snort $(SNORT_TARGET_DIR)/usr/bin/

	make -C $(SNORT_DIR) distclean

	(cd $(SNORT_DIR) ; ./configure $(CONFFLAGS) --with-mysql=$(BT_STAGING_DIR)/usr/ )
	make $(MAKEOPTS) -C $(SNORT_DIR)
	cp -a -f $(SNORT_DIR)/src/snort $(SNORT_TARGET_DIR)/usr/bin/snortsql

	cp -a -f $(SNORT_DIR)/etc/*.conf* $(SNORT_TARGET_DIR)/etc/snort/
	cp -a -f $(SNORT_DIR)/etc/*.map $(SNORT_TARGET_DIR)/etc/snort/
	cp -a -f $(SNORT_DIR)/etc/gen* $(SNORT_TARGET_DIR)/etc/snort/
	cp -a -f $(SNORT_DIR)/rules/*.rules $(SNORT_TARGET_DIR)/etc/snort/rules/
	cp -aL -f $(SNORT_INIT) $(SNORT_TARGET_DIR)/etc/init.d/snort
	chmod 755 $(SNORT_TARGET_DIR)/etc/init.d/snort
	cp -aL -f $(SNORT_DEFAULT) $(SNORT_TARGET_DIR)/etc/default/snort
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SNORT_TARGET_DIR)/usr/bin/*
	cp -a -f $(SNORT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SNORT_DIR)/.build


build: $(SNORT_DIR)/.build


clean:
	make -C $(SNORT_DIR) clean
	rm -rf $(SNORT_TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/bin/snort
	rm -rf $(BT_STAGING_DIR)/usr/bin/snortsql
	rm -rf $(BT_STAGING_DIR)/etc/snort
	rm -rf $(BT_STAGING_DIR)/etc/init.d/snort
	rm -rf $(BT_STAGING_DIR)/etc/default/snort
	rm -f $(SNORT_DIR)/.build
	rm -f $(SNORT_DIR)/.configured


srcclean: clean
	rm -rf $(SNORT_DIR)
	rm -f $(SNORT_DIR)/.source



