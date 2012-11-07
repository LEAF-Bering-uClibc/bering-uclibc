# makefile for squid

DIR:=bird-1.3.8
TARGET_DIR:=$(BT_BUILD_DIR)/bird

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(TARGET_DIR)/etc/init.d
	(cd $(DIR) ; \
	./configure prefix=/usr \
	--sysconfdir=/etc/bird \
	--localstatedir=/var \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-iproutedir="$(BT_STAGING_DIR)/etc/iproute2")
	perl -i -p -e "s, -s , -s --strip-program=$(GNU_TARGET_NAME)-strip ," $(DIR)/obj/Makefile
	make -C $(DIR) all
	make DESTDIR=$(TARGET_DIR) -C $(DIR) install
	make -C $(DIR) clean
	(cd $(DIR) ; \
	./configure prefix=/usr \
	--sysconfdir=/etc/bird \
	--localstatedir=/var \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-iproutedir="$(BT_STAGING_DIR)/etc/iproute2" \
	--enable-ipv6)
	perl -i -p -e "s, -s , -s --strip-program=$(GNU_TARGET_NAME)-strip ," $(DIR)/obj/Makefile
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
