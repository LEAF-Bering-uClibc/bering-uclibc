#############################################################
#
# buildtool makefile for openldap
#
#############################################################

include $(MASTERMAKEFILE)

OPENLDAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(OPENLDAP_SOURCE) 2>/dev/null )
ifeq ($(OPENLDAP_DIR),)
OPENLDAP_DIR:=$(shell cat DIRNAME)
endif
OPENLDAP_TARGET_DIR:=$(BT_BUILD_DIR)/openldap

# Option settings for 'configure':
#  Move files out from under /usr/local/
#  Do not build the Standalone LDAP Daemon, just the libraries
#  Explicitly disable Cyrus SASL support
CONFOPTS:= --build=$(GNU_HOST_NAME) --host=$(GNU_TARGET_NAME) \
	--prefix=/usr --disable-slapd --without-cyrus-sasl --with-tls=openssl

$(OPENLDAP_DIR)/.source:
	zcat $(OPENLDAP_SOURCE) | tar -xvf -
	echo $(OPENLDAP_DIR) > DIRNAME
	touch $(OPENLDAP_DIR)/.source

source: $(OPENLDAP_DIR)/.source

$(OPENLDAP_DIR)/.configure: $(OPENLDAP_DIR)/.source
	( cd $(OPENLDAP_DIR) ; LDFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib" \
	./configure $(CONFOPTS) )
	touch $(OPENLDAP_DIR)/.configure

build: $(OPENLDAP_DIR)/.configure
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(OPENLDAP_DIR)
	$(MAKE) -C $(OPENLDAP_DIR) DESTDIR=$(OPENLDAP_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(OPENLDAP_TARGET_DIR)/usr/lib/*.so
	cp -f $(OPENLDAP_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -f $(OPENLDAP_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
#        Fix up libldap.la / libldap_r dependency list
	perl -i -p -e 's,/usr/lib/liblber.la,-llber,' $(BT_STAGING_DIR)/usr/lib/libldap.la
	perl -i -p -e 's,/usr/lib/liblber.la,-llber,' $(BT_STAGING_DIR)/usr/lib/libldap_r.la

clean:
	rm -rf $(OPENLDAP_TARGET_DIR)
	$(MAKE) -C $(OPENLDAP_DIR) clean
	rm -f $(OPENLDAP_DIR)/.configure

srcclean: clean
	rm -rf $(OPENLDAP_DIR)
	-rm DIRNAME

