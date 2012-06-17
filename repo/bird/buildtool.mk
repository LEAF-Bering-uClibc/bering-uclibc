# makefile for squid
include $(MASTERMAKEFILE)

DIR:=bird-1.3.7
TARGET_DIR:=$(BT_BUILD_DIR)/bird

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(TARGET_DIR)/etc/init.d
	(cd $(DIR) ; \
	CFLAGS="$(BT_COPT_FLAGS)" \
	LDFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib $(LDFLAGS)" \
	./configure prefix=/usr \
	--sysconfdir=/etc/bird \
	--localstatedir=/var \
	--build=$(GNU_HOST_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--with-iproutedir="$(BT_STAGING_DIR)/etc/iproute2")
	make -C $(DIR) all
	make DESTDIR=$(TARGET_DIR) -C $(DIR) install
	make -C $(DIR) clean
	(cd $(DIR) ; \
	CFLAGS="$(BT_COPT_FLAGS)" \
	LDFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib $(LDFLAGS)" \
	./configure prefix=/usr \
	--sysconfdir=/etc/bird \
	--localstatedir=/var \
	--build=$(GNU_HOST_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--with-iproutedir="$(BT_STAGING_DIR)/etc/iproute2" \
	--enable-ipv6)
	make -C $(DIR) all
	make DESTDIR=$(TARGET_DIR) -C $(DIR) install
	make -C $(DIR) clean
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	cp -aL bird.init $(TARGET_DIR)/etc/init.d/bird
	cp -aL bird.init $(TARGET_DIR)/etc/init.d/bird6
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	make -C $(DIR) clean
	-rm -rf $(TARGET_DIR)
	-rm $(BT_STAGING_DIR)/usr/sbin/bird6
	-rm $(BT_STAGING_DIR)/usr/sbin/birdc6
	-rm $(BT_STAGING_DIR)/usr/sbin/bird
	-rm $(BT_STAGING_DIR)/usr/sbin/birdc
	-rm -rf $(BT_STAGING_DIR)/etc/bird
	-rm $(BT_STAGING_DIR)/etc/init.d/bird
	-rm $(BT_STAGING_DIR)/etc/init.d/bird6
	-rm -rf $(DIR)/.build

srcclean: clean
	rm -rf $(DIR)
	rm -rf $(DIR)/.source
