#############################################################
#
# libgcrypt
#
#############################################################

include $(MASTERMAKEFILE)
LIBGCRYPT_DIR:=libgcrypt-1.5.0
LIBGCRYPT_TARGET_DIR:=$(BT_BUILD_DIR)/libgcrypt

export LDFLAGS += $(EXTCCLDFLAGS)

source:
	bzcat $(LIBGCRYPT_SOURCE) | tar -xvf -

$(LIBGCRYPT_DIR)/Makefile: $(LIBGCRYPT_DIR)/configure
	(cd $(LIBGCRYPT_DIR); ./configure \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr \
			--disable-asm \
			--with-gpg-error-prefix=$(BT_STAGING_DIR)/usr \
			);

build: $(LIBGCRYPT_DIR)/Makefile
	mkdir -p $(LIBGCRYPT_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBGCRYPT_DIR)
	$(MAKE) DESTDIR=$(LIBGCRYPT_TARGET_DIR) -C $(LIBGCRYPT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBGCRYPT_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBGCRYPT_TARGET_DIR)/usr/lib/*.la
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
