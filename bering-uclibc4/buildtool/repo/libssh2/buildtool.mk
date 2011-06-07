#############################################################
#
# buildtool makefile for libssh2
#
#############################################################

include $(MASTERMAKEFILE)

LIBSSH2_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBSSH2_SOURCE) 2>/dev/null )
ifeq ($(LIBSSH2_DIR),)
LIBSSH2_DIR:=$(shell cat DIRNAME)
endif
LIBSSH2_TARGET_DIR:=$(BT_BUILD_DIR)/libssh2

OPENSSL_SOURCE:=openssl-[0-9].[0-9].[0-9][a-z].tar.gz
LIBSSL_PREFIX:=$(shell $(BT_TGZ_GETDIRNAME) ../openssl/$(OPENSSL_SOURCE) )

# Option settings for 'configure':
#   Move installed files out from under /usr/local/
CONFOPTS:= --build=$(GNU_TARGET_NAME) --host=$(GNU_HOST_NAME) \
	--prefix=/usr \
	--with-libssl \
	--with-libssl-prefix=$(BT_STAGING_DIR)/usr

$(LIBSSH2_DIR)/.source:
	zcat $(LIBSSH2_SOURCE) | tar -xvf -
	echo $(LIBSSH2_DIR) > DIRNAME
	touch $(LIBSSH2_DIR)/.source

source: $(LIBSSH2_DIR)/.source

$(LIBSSH2_DIR)/.configure: $(LIBSSH2_DIR)/.source
	( cd $(LIBSSH2_DIR) ; ./configure $(CONFOPTS) )
	touch $(LIBSSH2_DIR)/.configure

build: $(LIBSSH2_DIR)/.configure
	mkdir -p $(LIBSSH2_TARGET_DIR)
	$(MAKE) -C $(LIBSSH2_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD)
	$(MAKE) -C $(LIBSSH2_DIR) DESTDIR=$(LIBSSH2_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBSSH2_TARGET_DIR)/usr/lib/*.so
	cp -a -f $(LIBSSH2_TARGET_DIR)/usr/lib/libssh2* $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/lib/pkgconfig
	cp -a -f $(LIBSSH2_TARGET_DIR)/usr/lib/pkgconfig/libssh2.pc $(BT_STAGING_DIR)/usr/lib/pkgconfig/
	cp -a -f $(LIBSSH2_TARGET_DIR)/usr/include/libssh2* $(BT_STAGING_DIR)/usr/include/

clean:
	rm -rf $(LIBSSH2_TARGET_DIR)
	$(MAKE) -C $(LIBSSH2_DIR) clean
	rm -f $(LIBSSH2_DIR)/.configure

srcclean: clean
	rm -rf $(LIBSSH2_DIR) 
	-rm DIRNAME

