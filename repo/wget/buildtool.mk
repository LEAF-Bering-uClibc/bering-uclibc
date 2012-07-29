# makefile for wget
include $(MASTERMAKEFILE)

WGET_DIR:=wget-1.13.4
WGET_TARGET_DIR:=$(BT_BUILD_DIR)/wget
#CFLAGS="$(BT_COPT_FLAGS) -g -Wall -Wno-implicit -DINET6"
export CFLAGS += -g -Wall -Wno-implicit

$(WGET_DIR)/.source:
	zcat $(WGET_SOURCE) | tar -xvf -
	touch $(WGET_DIR)/.source

source: $(WGET_DIR)/.source

$(WGET_DIR)/.build: $(WGET_DIR)/.source
	mkdir -p $(WGET_TARGET_DIR)
	mkdir -p $(WGET_TARGET_DIR)/etc
	mkdir -p $(WGET_TARGET_DIR)/usr/bin

#CC=$(TARGET_CC) LD=$(TARGET_LD)
	#Build a version without SSL support
	(cd $(WGET_DIR) ; \
	./configure \
	     --prefix=/usr \
	     --host=$(GNU_TARGET_NAME) \
	     --build=$(GNU_BUILD_NAME) \
	     --sysconfdir=/etc \
	     --disable-nls \
	     --disable-debug \
	     --disable-iri \
	     --without-gpg-error \
	     --without-gcrpyt \
	     --without-ssl \
	)

	make $(MAKEOPTS) CC=$(TARGET_CC) -C $(WGET_DIR)
	cp -a $(WGET_DIR)/src/wget $(WGET_TARGET_DIR)/usr/bin
	make -C $(WGET_DIR) clean

# hack cause distclean removes files like src/css.c
#	zcat $(WGET_SOURCE) | tar -xvf -
	#Build a version with SSL support
	(cd $(WGET_DIR) ; \
	./configure \
	     --prefix=/usr \
	     --host=$(GNU_TARGET_NAME) \
	     --build=$(GNU_BUILD_NAME) \
	     --sysconfdir=/etc \
	     --disable-nls \
	     --disable-debug \
	     --disable-iri \
	     --without-gpg-error \
	     --without-gcrpyt \
	     --with-ssl=openssl \
	     --with-libssl-prefix=$(BT_STAGING_DIR)/usr \
	)
	make $(MAKEOPTS) -C $(WGET_DIR)
	cp -a $(WGET_DIR)/src/wget $(WGET_TARGET_DIR)/usr/bin/wget-ssl
	make -C $(WGET_DIR) clean

	cp -aL wgetrc $(WGET_TARGET_DIR)/etc
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(WGET_TARGET_DIR)/usr/bin/*
	cp -a $(WGET_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(WGET_DIR)/.build

build: $(WGET_DIR)/.build

clean:
	make -C $(WGET_DIR) clean
	rm -rf $(WGET_TARGET_DIR)
	rm -f $(WGET_DIR)/.build

srcclean: clean
	rm -rf $(WGET_DIR)
	rm -f $(WGET_DIR)/.source
