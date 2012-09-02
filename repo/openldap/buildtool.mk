#############################################################
#
# buildtool makefile for openldap
#
#############################################################

include $(MASTERMAKEFILE)

OPENLDAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(OPENLDAP_SOURCE) 2>/dev/null )
OPENLDAP_TARGET_DIR:=$(BT_BUILD_DIR)/openldap

# Option settings for 'configure':
#  Move files out from under /usr/local/
#  Do not build the Standalone LDAP Daemon, just the libraries
#  Explicitly disable Cyrus SASL support
CONFOPTS:= --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr --disable-slapd --without-cyrus-sasl --with-tls=openssl \
	--with-threads --with-mp=gmp --with-yielding-select=yes
export CC=$(TARGET_CC)
export AR=$(TARGET_AR)

$(OPENLDAP_DIR)/.source:
	zcat $(OPENLDAP_SOURCE) | tar -xvf -
	touch $(OPENLDAP_DIR)/.source

source: $(OPENLDAP_DIR)/.source

$(OPENLDAP_DIR)/.configure: $(OPENLDAP_DIR)/.source
	( cd $(OPENLDAP_DIR) ; ./configure $(CONFOPTS) )
	sed -i 's,#define NEED_MEMCMP_REPLACEMENT 1,/* undef NEED_MEMCMP_REPLACEMENT */,' $(OPENLDAP_DIR)/include/portable.h
	touch $(OPENLDAP_DIR)/.configure

build: $(OPENLDAP_DIR)/.configure
	# Fix rpath to avoid picking up libraries from build host's /usr/lib
	( cd $(OPENLDAP_DIR) ; find . -name Makefile -exec perl -i -p -e "s,^UNIX_LTFLAGS_LIB = .*,UNIX_LTFLAGS_LIB = \\$$\(LTVERSION) -rpath $(OPENLDAP_TARGET_DIR)/usr/lib," {} \; )
	$(MAKE) $(MAKEOPTS) -C $(OPENLDAP_DIR)
	$(MAKE) -C $(OPENLDAP_DIR)/include DESTDIR=$(OPENLDAP_TARGET_DIR) install
	$(MAKE) -C $(OPENLDAP_DIR)/libraries DESTDIR=$(OPENLDAP_TARGET_DIR) install
#
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENLDAP_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(OPENLDAP_TARGET_DIR)/usr/lib/*.so
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(OPENLDAP_TARGET_DIR)/usr/lib/*.la
	mkdir -p $(BT_STAGING_DIR)/usr/lib/
	mkdir -p $(BT_STAGING_DIR)/usr/include/
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

