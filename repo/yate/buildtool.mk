#############################################################
#
# buildtool makefile for yate
#
#############################################################

include $(MASTERMAKEFILE)

YATE_DIR:=yate
YATE_TARGET_DIR:=$(BT_BUILD_DIR)/yate
export AUTOCONF=$(BT_STAGING_DIR)/bin/autoconf
PERLVER:=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5 2>/dev/null)

$(YATE_DIR)/.source:
	zcat $(YATE_SOURCE) | tar -xvf -
	cat $(YATE_PATCH1) | patch -d $(YATE_DIR) -p1
	cat $(YATE_PATCH2) | patch -d $(YATE_DIR) -p1
	touch $(YATE_DIR)/.source

source: $(YATE_DIR)/.source

$(YATE_DIR)/.configured: $(YATE_DIR)/.source
	(cd $(YATE_DIR) ;  export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	$(AUTOCONF) ; CC=$(TARGET_CC) CXX=$(BT_STAGING_DIR)/usr/bin/g++ LD=$(TARGET_LD) \
			./configure \
			--build=$(GNU_HOST_NAME) \
			--host=$(GNU_HOST_NAME) \
			--prefix=/ \
			--disable-dahdi \
			--disable-zaptel \
			--disable-wpcard \
			--disable-tdmcard \
			--disable-wanpipe \
			--without-libgsm \
			--without-libspeex \
			--without-mysql \
			--without-libpq \
			--without-libqt4 \
			--without-openh323 \
			--without-openssl \
			--without-pwlib \
			--without-zlib \
			--mandir=/usr/man )
	touch $(YATE_DIR)/.configured

$(YATE_DIR)/.build: $(YATE_DIR)/.configured
	echo "YATE_TARGET_DIR=$(YATE_TARGET_DIR)"
	mkdir -p $(YATE_TARGET_DIR)
	make -C $(YATE_DIR) all
	touch $@

$(YATE_DIR)/.install: $(YATE_DIR)/.build
	make -C $(YATE_DIR) DESTDIR=$(YATE_TARGET_DIR) install-noapi
	install -d -m 0755 $(YATE_TARGET_DIR)/etc/init.d
	install    -m 0755 $(YATE_INIT) $(YATE_TARGET_DIR)/etc/init.d/yate
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(YATE_TARGET_DIR)/bin/yate
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(YATE_TARGET_DIR)/lib/*.so
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(YATE_TARGET_DIR)/lib/yate/*.yate
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(YATE_TARGET_DIR)/lib/yate/*/*.yate
	cp -a $(YATE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $@

build: $(YATE_DIR)/.install

clean:
	make -C $(YATE_DIR) clean
	rm -rf $(YATE_TARGET_DIR)

srcclean: clean
	rm -rf $(YATE_DIR) 

