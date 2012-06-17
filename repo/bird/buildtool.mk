# makefile for squid
include $(MASTERMAKEFILE)

DIR:=bird-1.3.7
TARGET_DIR:=$(BT_BUILD_DIR)/bird

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source
                        
$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; \
	CC=$(TARGET_CC) LD=$(TARGET_LD) \
	CFLAGS="$(BT_COPT_FLAGS)" \
	LDFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib $(LDFLAGS)" \
	./configure prefix=/usr \
	--sysconfdir=/etc/bird \
	--localstatedir=/var \
	--build=$(GNU_HOST_MANE) \
	--host=$(GNU_TARGET_MANE) \
	--with-iproutedir="$(BT_STAGING_DIR)/etc/iproute2" \
	--enable-ipv6)
	touch $(DIR)/.configured
#	--disable-client \
#	--with-sysinclude="$(BT_STAGING_DIR)/include" \
                                                                 
$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)/etc/init.d
	make -C $(DIR) all
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
