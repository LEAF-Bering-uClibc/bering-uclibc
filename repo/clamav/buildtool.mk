# makefile for clamav

CLAMAV_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(CLAMAV_SOURCE) 2>/dev/null )
CLAMAV_TARGET_DIR:=$(BT_BUILD_DIR)/clamav
export LDFLAGS += $(EXTCCLDFLAGS)

$(CLAMAV_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(CLAMAV_SOURCE)
	cat $(CLAMAV_PATCH1) | patch -d $(CLAMAV_DIR) -p1
	touch $(CLAMAV_DIR)/.source

source: $(CLAMAV_DIR)/.source

$(CLAMAV_DIR)/.configured: $(CLAMAV_DIR)/.source
	(cd $(CLAMAV_DIR) ; \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-sysroot=$(BT_STAGING_DIR) \
	--sysconfdir=/etc/clamav --prefix=/ \
	--includedir=/usr/include \
	--exec-prefix=/usr --libexecdir=/usr/bin \
	--datarootdir=/var/lib/clamav \
	--disable-clamav \
	--disable-clamuko \
	--disable-dsig \
	--disable-dns \
	--with-user=root \
	--with-group=root \
	--disable-nls \
	--without-iconv \
	--disable-static \
	--disable-llvm \
	--without-libcurl \
	--with-zlib=$(BT_STAGING_DIR)/usr \
	--with-openssl=$(BT_STAGING_DIR)/usr \
	--with-xml=$(BT_STAGING_DIR)/usr \
	--disable-zlib-vcheck \
	--disable-unrar \
	--datadir=/etc/clamav \
	--with-libncurses-prefix=$(BT_STAGING_DIR)/usr \
	--without-libpdcurses-prefix)


	touch $(CLAMAV_DIR)/.configured

$(CLAMAV_DIR)/.build: $(CLAMAV_DIR)/.configured
	mkdir -p $(CLAMAV_TARGET_DIR)
	mkdir -p $(CLAMAV_TARGET_DIR)/etc/clamav
	mkdir -p $(CLAMAV_TARGET_DIR)/etc/init.d
	make $(MAKEOPTS) -C $(CLAMAV_DIR) all
	make -C $(CLAMAV_DIR) DESTDIR=$(CLAMAV_TARGET_DIR) install
	rm -rf $(CLAMAV_TARGET_DIR)/share/man
	cp -aL rc.freshclam $(CLAMAV_TARGET_DIR)/etc/init.d/freshclam
	cp -aL rc.clamd $(CLAMAV_TARGET_DIR)/etc/init.d/clamd
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(CLAMAV_TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(CLAMAV_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(CLAMAV_TARGET_DIR)/usr/sbin/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(CLAMAV_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(CLAMAV_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	cp -a $(CLAMAV_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(CLAMAV_DIR)/.build

build: $(CLAMAV_DIR)/.build

clean:
	make -C $(CLAMAV_DIR) clean
	rm -rf $(CLAMAV_TARGET_DIR)
	rm -rf $(CLAMAV_DIR)/.build
	rm -rf $(CLAMAV_DIR)/.configured

srcclean: clean
	rm -rf $(CLAMAV_DIR)
