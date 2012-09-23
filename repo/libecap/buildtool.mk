#############################################################
#
# libecap
#
#############################################################

LIBECAP_DIR:=libecap-0.2.0
LIBECAP_TARGET_DIR:=$(BT_BUILD_DIR)/libecap

source:
	zcat $(LIBECAP_SOURCE) | tar -xvf -

$(LIBECAP_DIR)/Makefile: $(LIBECAP_DIR)/configure
	(cd $(LIBECAP_DIR); ./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--prefix=/usr );

build: $(LIBECAP_DIR)/Makefile
	mkdir -p $(LIBECAP_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBECAP_DIR)
	$(MAKE) DESTDIR=$(LIBECAP_TARGET_DIR) -C $(LIBECAP_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBECAP_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBECAP_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBECAP_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(LIBECAP_TARGET_DIR)/usr/man
	cp -a $(LIBECAP_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	echo $(PATH)
	-rm $(LIBECAP_DIR)/.build
	rm -rf $(LIBECAP_TARGET_DIR)
	$(MAKE) -C $(LIBECAP_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libecap*

srcclean: clean
	rm -rf $(LIBECAP_DIR)
