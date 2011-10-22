#############################################################
#
# libgcrypt
#
#############################################################

include $(MASTERMAKEFILE)
LIBGCRYPT_DIR:=libgcrypt-1.5.0
LIBGCRYPT_TARGET_DIR:=$(BT_BUILD_DIR)/libgcrypt
export CC=$(TARGET_CC)

source:
	bzcat $(LIBGCRYPT_SOURCE) | tar -xvf - 	

$(LIBGCRYPT_DIR)/Makefile: $(LIBGCRYPT_DIR)/configure
	(cd $(LIBGCRYPT_DIR); ac_cv_linux_vers=2  \
		CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS=$(CFLAGS) \
		./configure \
			--build=i686-pc-linux-gnu \
			--target=i686-pc-linux-gnu \
			--prefix=/usr );
	
build: $(LIBGCRYPT_DIR)/Makefile
	mkdir -p $(LIBGCRYPT_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBGCRYPT_DIR) 
	$(MAKE) DESTDIR=$(LIBGCRYPT_TARGET_DIR) -C $(LIBGCRYPT_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBGCRYPT_TARGET_DIR)/usr/lib/libgcrypt.so.11.7.0
	rm -rf $(LIBGCRYPT_TARGET_DIR)/usr/man
	cp -a $(LIBGCRYPT_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	echo $(PATH)
	-rm $(LIBGCRYPT_DIR)/.build
	rm -rf $(LIBGCRYPT_TARGET_DIR)
	$(MAKE) -C $(LIBGCRYPT_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libgcrypt*
	rm -f $(BT_STAGING_DIR)/usr/bin/libgcrypt-config
	
srcclean: clean
	rm -rf $(LIBGCRYPT_DIR)
