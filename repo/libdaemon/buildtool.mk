#############################################################
#
# libdaemon
#
#############################################################

include $(MASTERMAKEFILE)
LIBDAEMON_DIR:=libdaemon-0.14
LIBDAEMON_TARGET_DIR:=$(BT_BUILD_DIR)/libdaemon
export CC=$(TARGET_CC)

source:
	zcat $(LIBDAEMON_SOURCE) | tar -xvf - 	

$(LIBDAEMON_DIR)/Makefile: $(LIBDAEMON_DIR)/configure
	(cd $(LIBDAEMON_DIR); ac_cv_linux_vers=2  \
		CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS=$(CFLAGS) \
		./configure \
			--build=i686-pc-linux-gnu \
			--target=i686-pc-linux-gnu \
			--prefix=/usr \
			--without-check );
	
build: $(LIBDAEMON_DIR)/Makefile
	mkdir -p $(LIBDAEMON_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBDAEMON_DIR) 
	$(MAKE) DESTDIR=$(LIBDAEMON_TARGET_DIR) -C $(LIBDAEMON_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBDAEMON_TARGET_DIR)/usr/lib/libdaemon.so.0.5.0
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(LIBDAEMON_TARGET_DIR)/usr/lib/*.la
	rm -rf $(LIBDAEMON_TARGET_DIR)/usr/man
	cp -a $(LIBDAEMON_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	echo $(PATH)
	-rm $(LIBDAEMON_DIR)/.build
	rm -rf $(LIBDAEMON_TARGET_DIR)
	$(MAKE) -C $(LIBDAEMON_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libdaemon
	rm -f $(BT_STAGING_DIR)/usr/lib/libdaemon.*
	
srcclean:
	rm -rf $(LIBDAEMON_DIR)
