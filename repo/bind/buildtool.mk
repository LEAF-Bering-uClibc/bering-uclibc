# makefile for squid
include $(MASTERMAKEFILE)

DIR:=bind-9.8.0-P1
TARGET_DIR:=$(BT_BUILD_DIR)/bind
PERLVER=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source
                        
$(DIR)/.configured: $(DIR)/.source
#	(cd $(DIR) ; [ -$(PERLVER) = - ] || export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); 
	(cd $(DIR) ; \
	CFLAGS="$(BT_COPT_FLAGS)" \
	LDFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib $(LDFLAGS)" \
	./configure prefix=/usr \
	--sysconfdir=/etc/named \
	--localstatedir=/var \
	--target=$(GNU_TARGET_NAME) \
	--host=$(GNU_HOST_NAME) \
	--with-openssl=$(BT_STAGING_DIR)/usr \
	--enable-linux-caps \
	--enable-threads \
	--with-libtool \
	--without-idn \
	--enable-ipv6 \
	--without-gssapi \
	--with-randomdev=/dev/random \
	--disable-symtable \
	--without-libxml2 \
	--disable-static)
	touch $(DIR)/.configured
                                                                 
$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/etc/named
	mkdir -p $(TARGET_DIR)/etc/default
	mkdir -p $(TARGET_DIR)/var/named/pri
#       breaks patch
	[ -$(PERLVER) = - ] || PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	make -C $(DIR) all 
#	make CFLAGS="-Wall" -C $(DIR) all
	make DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	-rm -rf $(TARGET_DIR)/usr/share
	-perl -i -p -e 's,(['"'"'" L])(/usr)?/lib,\1$(BT_STAGING_DIR)\2/lib,g' $(TARGET_DIR)/usr/lib/*.la
	cp -aL named.init $(TARGET_DIR)/etc/init.d/named
	cp -aL named.conf $(TARGET_DIR)/etc/named
	cp -aL rndc.conf $(TARGET_DIR)/etc/named
	cp -aL named.default $(TARGET_DIR)/etc/default/named
	cp -aL named.cache $(TARGET_DIR)/var/named
	cp -aL *.zone $(TARGET_DIR)/var/named/pri
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build
                                                                                         
clean:
	make -C $(DIR) clean
	rm -rf $(TARGET_DIR)
	rm -rf $(DIR)/.build
	rm -rf $(DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(DIR) 
	rm -rf $(DIR)/.source
