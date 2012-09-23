# makefile for havp

HAVP_DIR:=havp-0.92a
HAVP_TARGET_DIR:=$(BT_BUILD_DIR)/havp
#MOUNT_DIR:=busybox-1.19.2

$(HAVP_DIR)/.source:
	zcat $(HAVP_SOURCE) | tar -xvf -
#	bzcat $(MOUNT_SOURCE) | tar -xvf -
	touch $(HAVP_DIR)/.source

source: $(HAVP_DIR)/.source

$(HAVP_DIR)/.configured: $(HAVP_DIR)/.source
	(cd $(HAVP_DIR) ; \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-clamav \
	--disable-trophie \
	--enable-ssl-tunnel \
	--sysconfdir=/etc/havp --prefix= \
	--libexecdir=/usr/bin \
	)
	touch $(HAVP_DIR)/.configured

$(HAVP_DIR)/.build: $(HAVP_DIR)/.configured
	mkdir -p $(HAVP_TARGET_DIR)
	mkdir -p $(HAVP_TARGET_DIR)/etc
	mkdir -p $(HAVP_TARGET_DIR)/etc/init.d
	mkdir -p $(HAVP_TARGET_DIR)/etc/havp
	make $(MAKEOPTS) -C $(HAVP_DIR) all
	make -C $(HAVP_DIR) DESTDIR=$(HAVP_TARGET_DIR) install
	cp -aL havp.config $(HAVP_TARGET_DIR)/etc/havp/havp.config
	cp -aL rc.havp.sh $(HAVP_TARGET_DIR)/etc/init.d/havp.sh
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HAVP_TARGET_DIR)/sbin/*
	cp -a $(HAVP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(HAVP_DIR)/.build

build: $(HAVP_DIR)/.build

clean:
	make -C $(HAVP_DIR) clean
	rm -rf $(HAVP_TARGET_DIR)
	rm -rf $(HAVP_DIR)/.build
	rm -rf $(HAVP_DIR)/.configured

srcclean: clean
	rm -rf $(HAVP_DIR)
	rm -rf $(HAVP_DIR)/.source
