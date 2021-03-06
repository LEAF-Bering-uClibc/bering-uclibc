#############################################################
#
# libosip2
#
#############################################################

LIBOSIP2_DIR=libosip2-2.2.2
LIBOSIP2_TARGET_DIR=$(BT_BUILD_DIR)/libosip

$(LIBOSIP2_DIR)/.source:
	zcat $(LIBOSIP2_SOURCE) | tar -xvf -
	touch $(LIBOSIP2_DIR)/.source

$(LIBOSIP2_DIR)/.configured: $(LIBOSIP2_DIR)/.source
	(cd $(LIBOSIP2_DIR) ; \
	./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME) \
		--prefix=/usr --disable-shared );
	touch $(LIBOSIP2_DIR)/.configured

$(LIBOSIP2_DIR)/.build: $(LIBOSIP2_DIR)/.configured
	mkdir -p $(LIBOSIP2_TARGET_DIR)
	mkdir -p $(LIBOSIP2_TARGET_DIR)/usr/lib
	$(MAKE) $(MAKEOPTS) -C $(LIBOSIP2_DIR)
	$(MAKE) -C $(LIBOSIP2_DIR) DESTDIR=$(LIBOSIP2_TARGET_DIR) install
	-rm -rf $(LIBOSIP2_TARGET_DIR)/usr/man
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBOSIP2_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBOSIP2_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBOSIP2_TARGET_DIR)/usr/lib/*
	cp -a $(LIBOSIP2_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBOSIP2_DIR)/.build

source: $(LIBOSIP2_DIR)/.source

build: $(LIBOSIP2_DIR)/.build

clean:
	make -C $(LIBOSIP2_DIR) clean
	rm $(LIBOSIP2_TARGET_DIR)/.build
	rm -rf $(LIBOSIP2_TARGET_DIR)

srcclean:
	rm -rf $(LIBOSIP2_DIR)
