#############################################################
#
# libgpg-error
#
#############################################################

include $(MASTERMAKEFILE)
LIBGPG-ERROR_DIR:=libgpg-error-1.10
LIBGPG-ERROR_TARGET_DIR:=$(BT_BUILD_DIR)/libgpgerror
export CC=$(TARGET_CC)

source:
	bzcat $(LIBGPGERROR_SOURCE) | tar -xvf - 	

$(LIBGPG-ERROR_DIR)/Makefile: $(LIBGPG-ERROR_DIR)/configure
	(cd $(LIBGPG-ERROR_DIR); ac_cv_linux_vers=2  \
		CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS=$(CFLAGS) \
		./configure \
			--build=i686-pc-linux-gnu \
			--target=i686-pc-linux-gnu \
			--prefix=/usr \
			--disable-nls --disable-languages );
	
build: $(LIBGPG-ERROR_DIR)/Makefile
	mkdir -p $(LIBGPG-ERROR_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBGPG-ERROR_DIR) 
	$(MAKE) DESTDIR=$(LIBGPG-ERROR_TARGET_DIR) -C $(LIBGPG-ERROR_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBGPG-ERROR_TARGET_DIR)/usr/lib/libgpg-error.so
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBGPG-ERROR_TARGET_DIR)/usr/bin/gpg-error
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
