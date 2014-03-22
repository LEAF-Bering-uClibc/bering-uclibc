#############################################################
#
# libdaemon
#
#############################################################

LIBDAEMON_DIR:=libdaemon-0.14
LIBDAEMON_TARGET_DIR:=$(BT_BUILD_DIR)/libdaemon

source:
	zcat $(LIBDAEMON_SOURCE) | tar -xvf -

$(LIBDAEMON_DIR)/Makefile: $(LIBDAEMON_DIR)/configure
	(cd $(LIBDAEMON_DIR); ac_cv_linux_vers=2  \
		./configure \
			--build=$(GNU_BUILD_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr \
			--disable-static \
			--without-check );
	
build: $(LIBDAEMON_DIR)/Makefile
	mkdir -p $(LIBDAEMON_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBDAEMON_DIR) 
	$(MAKE) DESTDIR=$(LIBDAEMON_TARGET_DIR) -C $(LIBDAEMON_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBDAEMON_TARGET_DIR)/usr/lib/libdaemon.so.0.5.0
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBDAEMON_TARGET_DIR)/usr/lib/*.la
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(LIBDAEMON_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBDAEMON_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(LIBDAEMON_TARGET_DIR)/usr/man
	cp -a $(LIBDAEMON_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	echo $(PATH)
	-rm $(LIBDAEMON_DIR)/.build
	rm -rf $(LIBDAEMON_TARGET_DIR)
	$(MAKE) -C $(LIBDAEMON_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libdaemon
	rm -f $(BT_STAGING_DIR)/usr/lib/libdaemon.*
	
srcclean: clean
	rm -rf $(LIBDAEMON_DIR)
