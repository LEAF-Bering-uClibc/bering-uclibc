#############################################################
#
# openssl
#
# $Id: buildtool.mk,v 1.6 2010/12/08 20:58:13 kapeka Exp $
#############################################################

include $(MASTERMAKEFILE)
OPENSSL_DIR:=openssl-1.0.0j
OPENSSL_TARGET_DIR:=$(BT_BUILD_DIR)/openssl

PERLVER:=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)

$(OPENSSL_DIR)/.source: 
	zcat $(OPENSSL_SOURCE) | tar -xvf -
#	zcat $(OPENSSL_PATCH1) | patch -d $(OPENSSL_DIR) -p1

	# Clean up the configure script
	perl -i -p -e 's,tcc=\"cc\";,tcc=\"$(TARGET_CC)\";,' $(OPENSSL_DIR)/Configure 
	touch $(OPENSSL_DIR)/.source

$(OPENSSL_DIR)/.configured: $(OPENSSL_DIR)/.source
	
	([ -$(PERLVER) = - ] || export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); cd $(OPENSSL_DIR); \
	./Configure linux-elf  \
		--prefix=/usr \
		--openssldir=/usr/ssl \
		-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib \
		-I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include \
		no-idea no-mdc2 no-rc5 no-hw no-krb5 shared no-fips no-threads  \
		 );	
	perl -i -p -e 's,\s*gcc\s+,\t$(TARGET_CC) ,' $(OPENSSL_DIR)/util/domd 
	perl -i -p -e 's,\s*gcc\s+,\t$(TARGET_CC) ,' $(OPENSSL_DIR)/util/pl/linux.pl 
	perl -i -p -e 's,\s*gcc\s+,\t$(TARGET_CC) ,' $(OPENSSL_DIR)/crypto/bn/Makefile 	
	perl -i -p -e 's,AR=ar.*,AR=$(BT_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ar r,' $(OPENSSL_DIR)/Makefile
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
	
	export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	make CC=$(TARGET_CC) -C $(OPENSSL_DIR) depend
	make CC=$(TARGET_CC) -C $(OPENSSL_DIR) 
	$(BT_STRIP) --strip-unneeded $(OPENSSL_DIR)/libcrypto.so.1.0.0
	$(BT_STRIP) --strip-unneeded $(OPENSSL_DIR)/libssl.so.1.0.0		
	make CC=$(TARGET_CC) -C $(OPENSSL_DIR) INSTALL_PREFIX=$(OPENSSL_TARGET_DIR) install
	$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(OPENSSL_TARGET_DIR)/usr/bin/openssl
	cp -af $(OPENSSL_TARGET_DIR)/usr/bin/openssl  $(BT_STAGING_DIR)/usr/bin/
	cp -af $(OPENSSL_TARGET_DIR)/usr/bin/c_rehash  $(BT_STAGING_DIR)/usr/bin/
	cp -af $(OPENSSL_TARGET_DIR)/usr/lib/lib*  $(BT_STAGING_DIR)/usr/lib/
	cp -af $(OPENSSL_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/  	
	cp -af $(OPENSSL_TARGET_DIR)/usr/ssl/misc/* $(BT_STAGING_DIR)/usr/ssl/misc/  	
	cp -f $(OPENSSL_TARGET_DIR)/usr/ssl/openssl.cnf $(BT_STAGING_DIR)/etc/ssl/
	# workaround for strange behaviour of install, dir is not readable and so not removable
	-chmod 755 $(OPENSSL_TARGET_DIR)/usr/lib/pkgconfig
	touch $(OPENSSL_DIR)/.build

source: $(OPENSSL_DIR)/.source

build: $(OPENSSL_DIR)/.build

clean: 
	-rm $(OPENSSL_DIR)/.build
	rm -f $(BT_STAGING_DIR)/bin/openssl  
	rm -f $(BT_STAGING_DIR)/lib/libcrypto.so* 
	rm -f $(BT_STAGING_DIR)/lib/libssl.so* 
	rm -rf $(OPENSSL_BUILD_DIR)
	-$(MAKE) -C $(OPENSSL_DIR) clean

srcclean: 
	rm -f $(BT_STAGING_DIR)/bin/openssl  
	rm -f $(BT_STAGING_DIR)/lib/libcrypto.so* 
	rm -f $(BT_STAGING_DIR)/lib/libssl.so* 
	rm -rf $(OPENSSL_BUILD_DIR)
	rm -rf $(OPENSSL_DIR)
