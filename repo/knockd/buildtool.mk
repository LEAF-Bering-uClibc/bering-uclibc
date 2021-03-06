# makefile for pmacctd

KNOCKD_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(KNOCKD_SOURCE) 2>/dev/null )
KNOCKD_TARGET_DIR:=$(BT_BUILD_DIR)/knockd

$(KNOCKD_DIR)/.source:
	zcat $(KNOCKD_SOURCE) | tar -xvf -
	zcat $(BT_TOOLS_DIR)/config.sub.gz >$(KNOCKD_DIR)/config.sub
	touch $(KNOCKD_DIR)/.source

source: $(KNOCKD_DIR)/.source

$(KNOCKD_DIR)/.configured: $(KNOCKD_DIR)/.source
	(cd $(KNOCKD_DIR) ; \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr  )
	touch $(KNOCKD_DIR)/.configured

$(KNOCKD_DIR)/.build: $(KNOCKD_DIR)/.configured
	mkdir -p $(KNOCKD_TARGET_DIR)
	mkdir -p $(KNOCKD_TARGET_DIR)/etc/init.d
	mkdir -p $(KNOCKD_TARGET_DIR)/etc/default
	mkdir -p $(KNOCKD_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(KNOCKD_DIR) 
	cp -aL knockd.init $(KNOCKD_TARGET_DIR)/etc/init.d/knockd
	cp -aL knockd.conf $(KNOCKD_TARGET_DIR)/etc
	cp -aL knockd.default $(KNOCKD_TARGET_DIR)/etc/default/knockd
	cp -a $(KNOCKD_DIR)/knockd $(KNOCKD_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(KNOCKD_TARGET_DIR)/usr/sbin/*
	cp -a $(KNOCKD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(KNOCKD_DIR)/.build

build: $(KNOCKD_DIR)/.build

clean:
	make -C $(KNOCKD_DIR) clean
	rm -rf $(KNOCKD_TARGET_DIR)
	rm -rf $(KNOCKD_DIR)/.build
	rm -rf $(KNOCKD_DIR)/.configured

srcclean: clean
	rm -rf $(KNOCKD_DIR)
