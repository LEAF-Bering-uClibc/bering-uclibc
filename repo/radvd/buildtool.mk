# makefile for radvd
include $(MASTERMAKEFILE)

RADVD_DIR:=radvd-1.9.1
RADVD_TARGET_DIR:=$(BT_BUILD_DIR)/radvd

$(RADVD_DIR)/.source:
	zcat $(RADVD_SOURCE) | tar -xvf -
	touch $(RADVD_DIR)/.source

source: $(RADVD_DIR)/.source

$(RADVD_DIR)/.configured: $(RADVD_DIR)/.source
	(cd $(RADVD_DIR) ; ./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--sysconfdir=/etc --prefix=/usr --mandir=/usr/share/man )
	touch $(RADVD_DIR)/.configured

$(RADVD_DIR)/.build: $(RADVD_DIR)/.configured
	mkdir -p $(RADVD_TARGET_DIR)
	mkdir -p $(RADVD_TARGET_DIR)/etc/init.d
	mkdir -p $(RADVD_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(RADVD_DIR)
	cp -a $(RADVD_DIR)/radvd $(RADVD_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(RADVD_TARGET_DIR)/usr/sbin/*
	cp -aL radvd.conf $(RADVD_TARGET_DIR)/etc
	cp -aL radvd.init $(RADVD_TARGET_DIR)/etc/init.d/radvd
	cp -a $(RADVD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(RADVD_DIR)/.build

build: $(RADVD_DIR)/.build

clean:
	rm -rf $(RADVD_TARGET_DIR)
	$(MAKE) -C $(RADVD_DIR) clean
	rm -f $(RADVD_DIR)/.build
	rm -f $(RADVD_DIR)/.configured

srcclean: clean
	rm -rf $(RADVD_DIR)
