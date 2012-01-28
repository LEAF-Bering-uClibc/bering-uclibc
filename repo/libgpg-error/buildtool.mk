#############################################################
#
# libgpg-error
#
#############################################################

include $(MASTERMAKEFILE)
LIBGPG-ERROR_DIR:=libgpg-error-1.10
LIBGPG-ERROR_TARGET_DIR:=$(BT_BUILD_DIR)/libgpgerror

source:
	bzcat $(LIBGPGERROR_SOURCE) | tar -xvf -

$(LIBGPG-ERROR_DIR)/Makefile: $(LIBGPG-ERROR_DIR)/configure
	(cd $(LIBGPG-ERROR_DIR); ./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--prefix=/usr \
			--disable-nls --disable-languages );

build: $(LIBGPG-ERROR_DIR)/Makefile
	mkdir -p $(LIBGPG-ERROR_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBGPG-ERROR_DIR)
	$(MAKE) DESTDIR=$(LIBGPG-ERROR_TARGET_DIR) -C $(LIBGPG-ERROR_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBGPG-ERROR_TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBGPG-ERROR_TARGET_DIR)/usr/bin/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBGPG-ERROR_TARGET_DIR)/usr/lib/*.la
	rm -rf $(LIBGPG-ERROR_TARGET_DIR)/usr/man
	cp -a $(LIBGPG-ERROR_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	echo $(PATH)
	-rm $(LIBGPG-ERROR_DIR)/.build
	rm -rf $(LIBGPG-ERROR_TARGET_DIR)
	$(MAKE) -C $(LIBGPG-ERROR_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libgpg-error*
	rm -f $(BT_STAGING_DIR)/usr/include/gpg-error.h
	rm -f $(BT_STAGING_DIR)/usr/bin/gpg-error*

srcclean: clean
	rm -rf $(LIBGPG-ERROR_DIR)
