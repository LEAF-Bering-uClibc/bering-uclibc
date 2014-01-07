#############################################################
#
# buildtool makefile for openssl
#
#############################################################

SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/openssl

.source:
	zcat $(SOURCE_TGZ) | tar -xvf -
	touch .source

source: .source

.configured: .source
	# $(OPENSSL_TARGET) is set in make/toolchain/*.mk
	(cd $(SOURCE_DIR); \
	./Configure $(OPENSSL_TARGET)  \
		--prefix=/usr \
		--openssldir=/usr/ssl \
		--libdir=lib \
		--install_prefix=$(TARGET_DIR) \
		--cross-compile-prefix=$(CROSS_COMPILE) \
		$(OPENSSL_EC_NISTP_64) \
		no-idea no-mdc2 no-rc5  no-krb5 shared no-fips threads  \
		-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib \
		-I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include \
		 );
	touch .configured

.build: .configured
	-mkdir -p $(TARGET_DIR)
	-mkdir -p $(BT_STAGING_DIR)/usr/lib
	-mkdir -p $(BT_STAGING_DIR)/usr/include
	-mkdir -p $(BT_STAGING_DIR)/usr/share/ssl
	-mkdir -p $(BT_STAGING_DIR)/etc/ssl
	-mkdir -p $(BT_STAGING_DIR)/etc/certs
	-mkdir -p $(BT_STAGING_DIR)/etc/private
	-mkdir -p $(BT_STAGING_DIR)/usr/ssl/misc

	make -C $(SOURCE_DIR) depend
	make -C $(SOURCE_DIR)
	make -C $(SOURCE_DIR) INSTALL_PREFIX=$(TARGET_DIR) install_sw
	# workaround for strange behaviour of install, on permissions
	-chmod -R 755 $(TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/engines/*.so
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	rm -rf $(TARGET_DIR)/usr/ssl/man
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	-rm .configured
	-rm .build
	-rm -f $(BT_STAGING_DIR)/bin/openssl
	-rm -f $(BT_STAGING_DIR)/usr/lib/libcrypto.so*
	-rm -f $(BT_STAGING_DIR)/usr/lib/libssl.so*
	-rm -f $(BT_STAGING_DIR)/usr/lib/engines/*
	-rm -rf $(BT_STAGING_DIR)/usr/ssl
	-$(MAKE) -C $(SOURCE_DIR) clean

srcclean: clean
	-rm -rf $(SOURCE_DIR)
	-rm .source
