######################################
#
# buildtool make file for libupnp & linux-igd
#
######################################


TARGET_DIR=$(BT_BUILD_DIR)/upnpd

UPNPD_DIR:=linuxigd-1.0
LIBUPNP_DIR:=libupnp-1.4.1

# ----------------------------------------------------------------------

LIBUPNP_FLAGS= DESTDIR=$(TARGET_DIR)

$(LIBUPNP_DIR)/.source:
	zcat $(LIBUPNP_SOURCE) | tar -xvf -
	touch $(LIBUPNP_DIR)/.source

$(LIBUPNP_DIR)/.configured: $(LIBUPNP_DIR)/.source
	(cd $(LIBUPNP_DIR); ./configure \
	--prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-shared );
	touch $(LIBUPNP_DIR)/.configured

$(LIBUPNP_DIR)/.build: $(LIBUPNP_DIR)/.configured
	mkdir -p $(TARGET_DIR)
	make $(MAKEOPTS) -C $(LIBUPNP_DIR)
	make -C $(LIBUPNP_DIR) DESTDIR=$(TARGET_DIR) install
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(TARGET_DIR)/usr/lib/pkgconfig/*.pc
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(TARGET_DIR)/usr/lib/*.la
	touch $(LIBUPNP_DIR)/.build

# ----------------------------------------------------------------------

UPNPD_FLAGS=$(DEBUG) HAVE_LIBIPTC=YES \
	LIBUPNP_PREFIX=$(TARGET_DIR)/usr \
	LIBIPTC_PREFIX=$(BT_STAGING_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) \
	CFLAGS="$(CFLAGS) $(EXTCCLDFLAGS)" \
	DESTDIR=$(TARGET_DIR)

$(UPNPD_DIR)/.source:
	zcat $(LINUXIGD_SOURCE) | tar -xvf -
	cat $(LINUXIGD_PATCH1) | patch -d $(UPNPD_DIR) -p1
	cat $(LINUXIGD_PATCH2) | patch -d $(UPNPD_DIR) -p1
#	cat $(LINUXIGD_PATCH3) | patch -d $(UPNPD_DIR) -p1
	cat $(LINUXIGD_PATCH4) | patch -d $(UPNPD_DIR) -p1
	cat $(LINUXIGD_PATCH5) | patch -d $(UPNPD_DIR) -p1
	touch $(UPNPD_DIR)/.source

$(UPNPD_DIR)/.build: $(UPNPD_DIR)/.source $(LIBUPNP_DIR)/.build
	make $(MAKEOPTS) -C $(UPNPD_DIR) $(UPNPD_FLAGS)
	make -C $(UPNPD_DIR) $(UPNPD_FLAGS) install
	cp $(UPNPD_DIR)/etc/ligd.gif    $(TARGET_DIR)/etc/linuxigd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	touch $(UPNPD_DIR)/.build

# ----------------------------------------------------------------------

.build:
	install -d $(TARGET_DIR)/etc/default
	install -d $(TARGET_DIR)/etc/init.d
	cp upnpd-default	$(TARGET_DIR)/etc/default/upnpd
	cp upnpd-init	 	$(TARGET_DIR)/etc/init.d/upnpd
	touch .build

# ----------------------------------------------------------------------

source: $(LIBUPNP_DIR)/.source $(UPNPD_DIR)/.source

build:	$(UPNPD_DIR)/.build .build
	cp -af $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	@if [ -d $(UPNPD_DIR) ]   ; then make -C $(UPNPD_DIR) clean ; fi
	@if [ -d $(LIBUPNP_DIR) ] ; then make -C $(LIBUPNP_DIR)/upnp clean ; fi
	rm -rf $(TARGET_DIR)
	rm -f  $(LIBUPNP_DIR)/.build
	rm -f  $(UPNPD_DIR)/.build
	rm -f  .build

stageclean:
	rm -rf $(BT_STAGING_DIR)/etc/linuxigd
	rm -f  $(BT_STAGING_DIR)/etc/init.d/upnpd
	rm -f  $(BT_STAGING_DIR)/etc/default/upnpd
	rm -f  $(BT_STAGING_DIR)/usr/sbin/upnpd
	rm -f  $(BT_STAGING_DIR)/usr/lib/libupnp*
	rm -f  $(BT_STAGING_DIR)/usr/lib/libixml*
	rm -f  $(BT_STAGING_DIR)/usr/lib/libthreadutil*
	rm -rf $(BT_STAGING_DIR)/usr/include/upnp

srcclean: clean
	rm -rf $(UPNPD_DIR)
	rm -rf $(LIBUPNP_DIR)
