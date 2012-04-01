#############################################################
#
# openssl
#
# $Id: buildtool.mk,v 1.6 2010/12/08 20:58:13 kapeka Exp $
#############################################################

include $(MASTERMAKEFILE)
OPENSSL_DIR:=openssl-1.0.1
OPENSSL_TARGET_DIR:=$(BT_BUILD_DIR)/openssl

$(OPENSSL_DIR)/.source:
	zcat $(OPENSSL_SOURCE) | tar -xvf -

#	# Clean up the configure script
#	perl -i -p -e 's,tcc=\"cc\";,tcc=\"$(TARGET_CC)\";,' $(OPENSSL_DIR)/Configure
	touch $(OPENSSL_DIR)/.source

$(OPENSSL_DIR)/.configured: $(OPENSSL_DIR)/.source

	(cd $(OPENSSL_DIR); \
	./Configure $(OPENSSL_TARGET)  \
		--prefix=/usr \
		--openssldir=/usr/ssl \
		--install_prefix=$(OPENSSL_TARGET_DIR) \
		--cross-compile-prefix=$(CROSS_COMPILE) \
		no-ssl3 no-idea no-mdc2 no-rc5  no-krb5 shared no-fips no-threads  \
		-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib \
		-I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include \
		 );
	touch $(OPENSSL_DIR)/.configured

$(OPENSSL_DIR)/.build: $(OPENSSL_DIR)/.configured
	-mkdir -p $(OPENSSL_TARGET_DIR)
	-mkdir -p $(BT_STAGING_DIR)/usr/lib
	-mkdir -p $(BT_STAGING_DIR)/usr/include
	-mkdir -p $(BT_STAGING_DIR)/usr/share/ssl
	-mkdir -p $(BT_STAGING_DIR)/etc/ssl
	-mkdir -p $(BT_STAGING_DIR)/etc/certs
	-mkdir -p $(BT_STAGING_DIR)/etc/private
	-mkdir -p $(BT_STAGING_DIR)/usr/ssl/misc

#Use building in 1 thread due to buggy makefile
	make -C $(OPENSSL_DIR) depend
	make -C $(OPENSSL_DIR)
	make -C $(OPENSSL_DIR) INSTALL_PREFIX=$(OPENSSL_TARGET_DIR) install_sw
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(OPENSSL_TARGET_DIR)/usr/lib/* $(OPENSSL_TARGET_DIR)/usr/lib/engines/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSSL_TARGET_DIR)/usr/bin/*
	rm -rf $(OPENSSL_TARGET_DIR)/usr/ssl/man
	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(OPENSSL_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	cp -a $(OPENSSL_TARGET_DIR)/* $(BT_STAGING_DIR)
	# workaround for strange behaviour of install, dir is not readable and so not removable
	-chmod 755 $(OPENSSL_TARGET_DIR)/usr/lib/pkgconfig
	touch $(OPENSSL_DIR)/.build

source: $(OPENSSL_DIR)/.source

build: $(OPENSSL_DIR)/.build

clean:
	-rm $(OPENSSL_DIR)/.build
	-rm -f $(BT_STAGING_DIR)/bin/openssl
	-rm -f $(BT_STAGING_DIR)/usr/lib/libcrypto.so*
	-rm -f $(BT_STAGING_DIR)/usr/lib/libssl.so*
	-rm -f $(BT_STAGING_DIR)/usr/lib/engines/*
	-rm -rf $(BT_STAGING_DIR)/usr/ssl
	-rm -rf $(OPENSSL_BUILD_DIR)
	-$(MAKE) -C $(OPENSSL_DIR) clean

srcclean:
	-rm -f $(BT_STAGING_DIR)/bin/openssl
	-rm -f $(BT_STAGING_DIR)/usr/lib/libcrypto.so*
	-rm -f $(BT_STAGING_DIR)/usr/lib/libssl.so*
	-rm -rf $(BT_STAGING_DIR)/usr/ssl
	-rm -rf $(OPENSSL_BUILD_DIR)
	-rm -rf $(OPENSSL_DIR)
