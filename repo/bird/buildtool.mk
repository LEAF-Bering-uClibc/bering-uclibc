# makefile for squid
include $(MASTERMAKEFILE)

DIR:=bird-1.3.1
TARGET_DIR:=$(BT_BUILD_DIR)/bird

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; \
	./configure prefix=/usr \
	--sysconfdir=/etc/bird \
	--localstatedir=/var \
	--host=$(GNU_TARGET_NAME) \
	--with-iproutedir="$(BT_STAGING_DIR)/etc/iproute2" \
	--enable-ipv6)
	touch $(DIR)/.configured
#	--disable-client \
#	--with-sysinclude="$(BT_STAGING_DIR)/include" \

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)/etc/init.d
	make $(MAKEOPTS) -C $(DIR) all
	make DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	cp -aL bird.init $(TARGET_DIR)/etc/init.d/bird
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	make -C $(DIR) clean
	-rm -rf $(TARGET_DIR)
	-rm $(BT_STAGING_DIR)/usr/sbin/bird6
	-rm $(BT_STAGING_DIR)/usr/sbin/birdc6
	-rm -rf $(BT_STAGING_DIR)/etc/bird
	-rm $(BT_STAGING_DIR)/etc/init.d/bird
	-rm -rf $(DIR)/.build
	-rm -rf $(DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(DIR) 
	rm -rf $(DIR)/.source
