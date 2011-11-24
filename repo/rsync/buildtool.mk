include $(MASTERMAKEFILE)
RSYNC_DIR:=rsync-3.0.9
RSYNC_TARGET_DIR:=$(BT_BUILD_DIR)/rsync

$(RSYNC_DIR)/.source:
	zcat $(RSYNC_SOURCE) | tar -xvf -
	touch $(RSYNC_DIR)/.source

$(RSYNC_DIR)/.configured: $(RSYNC_DIR)/.source
	cd $(RSYNC_DIR); ./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/usr \
		--disable-locale \
		--disable-iconv
	touch $(RSYNC_DIR)/.configured

$(RSYNC_DIR)/.build: $(RSYNC_DIR)/.configured
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	$(MAKE) $(MAKEOPTS) -C $(RSYNC_DIR) DESTDIR=$(RSYNC_TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(RSYNC_TARGET_DIR)/usr/bin/*
	-rm -rf $(RSYNC_TARGET_DIR)/usr/share
	cp -a -f $(RSYNC_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(RSYNC_DIR)/.build

source: $(RSYNC_DIR)/.source

build: $(RSYNC_DIR)/.build

clean:
	-$(MAKE) -C $(RSYNC_DIR) clean
	rm -rf $(RSYNC_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/bin/rsync
	-rm $(RSYNC_DIR)/.build

srcclean:
	rm -rf $(RSYNC_DIR)
