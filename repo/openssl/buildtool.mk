#############################################################
#
# openssl
#
# $Id: buildtool.mk,v 1.6 2010/12/08 20:58:13 kapeka Exp $
#############################################################

include $(MASTERMAKEFILE)
OPENSSL_DIR:=openssl-1.0.0e
OPENSSL_TARGET_DIR:=$(BT_BUILD_DIR)/openssl

$(OPENSSL_DIR)/.source: 
	zcat $(OPENSSL_SOURCE) | tar -xvf -
#	zcat $(OPENSSL_PATCH1) | patch -d $(OPENSSL_DIR) -p1

#	# Clean up the configure script
#	perl -i -p -e 's,tcc=\"cc\";,tcc=\"$(TARGET_CC)\";,' $(OPENSSL_DIR)/Configure 
	touch $(OPENSSL_DIR)/.source

$(OPENSSL_DIR)/.configured: $(OPENSSL_DIR)/.source
	
	(cd $(OPENSSL_DIR); \
	./Configure linux-elf  \
		--prefix=/usr \
		--openssldir=/usr/ssl \
		--install_prefix=$(OPENSSL_TARGET_DIR) \
		--cross-compile-prefix=$(CROSS_COMPILE) \
		no-ssl3 no-tls1 no-idea no-mdc2 no-rc5 no-hw no-krb5 shared no-fips no-threads  \
		-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib \
		-I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include \
		 );
#	perl -i -p -e 's,\s*gcc\s+,\t$(TARGET_CC) ,' $(OPENSSL_DIR)/util/domd 
#	perl -i -p -e 's,\s*gcc\s+,\t$(TARGET_CC) ,' $(OPENSSL_DIR)/util/pl/linux.pl 
#	perl -i -p -e 's,\s*gcc\s+,\t$(TARGET_CC) ,' $(OPENSSL_DIR)/crypto/bn/Makefile 	
#	perl -i -p -e 's,AR=ar.*,AR=$(BT_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ar r,' $(OPENSSL_DIR)/Makefile
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
	make -C $(OPENSSL_DIR) INSTALL_PREFIX=$(OPENSSL_TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(OPENSSL_TARGET_DIR)/usr/lib/* $(OPENSSL_TARGET_DIR)/usr/lib/engines/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSSL_TARGET_DIR)/usr/bin/*
	$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(OPENSSL_TARGET_DIR)/usr/bin/openssl
	rm -rf $(OPENSSL_TARGET_DIR)/usr/ssl/man
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
