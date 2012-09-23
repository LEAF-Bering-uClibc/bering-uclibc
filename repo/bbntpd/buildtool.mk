
BBNTPD_DIR=bbntpd
BBNTPD_BUILD_DIR=$(BT_BUILD_DIR)/bbntpd

$(BBNTPD_DIR)/.source:
	mkdir -p $(BBNTPD_DIR)
	touch $(BBNTPD_DIR)/.source

$(BBNTPD_DIR)/.build: $(BBNTPD_DIR)/.source
	mkdir -p $(BBNTPD_BUILD_DIR)
	mkdir -p $(BBNTPD_BUILD_DIR)/etc/init.d
	mkdir -p $(BBNTPD_BUILD_DIR)/etc/default
	-mkdir -p $(BT_STAGING_DIR)/etc/init.d
	-mkdir -p $(BT_STAGING_DIR)/etc/default

	cp -aL ntpd $(BBNTPD_BUILD_DIR)/etc/init.d/ntpd
	cp -aL ntpd.default $(BBNTPD_BUILD_DIR)/etc/default/ntpd
	cp -a $(BBNTPD_BUILD_DIR)/* $(BT_STAGING_DIR)
	cp -a $(BBNTPD_BUILD_DIR)/etc/init.d/* $(BT_STAGING_DIR)/etc/init.d/
	cp -a $(BBNTPD_BUILD_DIR)/etc/default/* $(BT_STAGING_DIR)/etc/default/
	touch $(BBNTPD_DIR)/.build

source: $(BBNTPD_DIR)/.source

build: $(BBNTPD_DIR)/.build

clean:
	-rm $(BBNTPD_DIR)/.build
	-rm -r $(BBNTPD_BUILD_DIR)

srcclean:
	rm -rf $(BBNTPD_DIR)
