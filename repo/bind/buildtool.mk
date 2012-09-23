# makefile for squid

DIR:=bind-9.8.1-P1
TARGET_DIR:=$(BT_BUILD_DIR)/bind

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(DIR)
	cat $(PATCH2) | patch -p1 -d $(DIR)
#	perl -i -p -e 's,\s+driver.o, .libs/driver.o,'  $(DIR)/bin/tests/system/dlzexternal/Makefile.in
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; BUILD_CC=gcc \
	./configure prefix=/usr \
	--sysconfdir=/etc/named \
	--localstatedir=/var \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-openssl=$(BT_STAGING_DIR)/usr \
	--enable-linux-caps \
	--enable-threads \
	--with-libtool \
	--without-idn \
	--enable-ipv6 \
	--enable-epoll \
	--without-gost \
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
	make $(MAKEOPTS) -C $(DIR) all
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
