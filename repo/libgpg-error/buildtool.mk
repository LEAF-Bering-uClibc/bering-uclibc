#############################################################
# makefile for libgpg-error
#############################################################

#LIBGPG-ERROR_DIR:=libgpg-error-1.10

LIBGPGERROR_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBGPGERROR_SOURCE) 2>/dev/null)
LIBGPG-ERROR_TARGET_DIR:=$(BT_BUILD_DIR)/libgpgerror

source:
	$(BT_SETUP_BUILDDIR) -v $(LIBGPGERROR_SOURCE)
#	bzcat $(LIBGPGERROR_SOURCE) | tar -xvf -

$(LIBGPGERROR_DIR)/Makefile: $(LIBGPGERROR_DIR)/configure
	(cd $(LIBGPGERROR_DIR); ./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--prefix=/usr \
			--disable-nls --disable-languages );

build: $(LIBGPGERROR_DIR)/Makefile
	mkdir -p $(LIBGPG-ERROR_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBGPGERROR_DIR)
	$(MAKE) DESTDIR=$(LIBGPG-ERROR_TARGET_DIR) -C $(LIBGPGERROR_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBGPG-ERROR_TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBGPG-ERROR_TARGET_DIR)/usr/bin/*
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBGPG-ERROR_TARGET_DIR)/usr/lib/*.la
	rm -rf $(LIBGPG-ERROR_TARGET_DIR)/usr/man
	cp -a $(LIBGPG-ERROR_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	echo $(PATH)
	-rm $(LIBGPGERROR_DIR)/.build
	rm -rf $(LIBGPG-ERROR_TARGET_DIR)
	$(MAKE) -C $(LIBGPGERROR_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libgpg-error*
	rm -f $(BT_STAGING_DIR)/usr/include/gpg-error.h
	rm -f $(BT_STAGING_DIR)/usr/bin/gpg-error*

srcclean: clean
	rm -rf $(LIBGPGERROR_DIR)
