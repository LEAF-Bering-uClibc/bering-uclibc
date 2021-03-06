#############################################################
#
# buildtool makefile for libssh2
#
#############################################################


LIBSSH2_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBSSH2_SOURCE) 2>/dev/null )
LIBSSH2_TARGET_DIR:=$(BT_BUILD_DIR)/libssh2

export LDFLAGS += $(EXTCCLDFLAGS)

# Option settings for 'configure':
#   Move installed files out from under /usr/local/
CONFOPTS:= --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr \
	--with-libssl \
	--with-libssl-prefix=$(BT_STAGING_DIR)/usr

$(LIBSSH2_DIR)/.source:
	zcat $(LIBSSH2_SOURCE) | tar -xvf -
	touch $(LIBSSH2_DIR)/.source

source: $(LIBSSH2_DIR)/.source

$(LIBSSH2_DIR)/.configure: $(LIBSSH2_DIR)/.source
	( cd $(LIBSSH2_DIR) ; ./configure $(CONFOPTS) )
	touch $(LIBSSH2_DIR)/.configure

build: $(LIBSSH2_DIR)/.configure
	mkdir -p $(LIBSSH2_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(LIBSSH2_DIR)
	$(MAKE) -C $(LIBSSH2_DIR) DESTDIR=$(LIBSSH2_TARGET_DIR) install
#
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBSSH2_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBSSH2_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBSSH2_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(LIBSSH2_TARGET_DIR)/usr/share
	cp -a -f $(LIBSSH2_TARGET_DIR)/* $(BT_STAGING_DIR)/

clean:
	rm -rf $(LIBSSH2_TARGET_DIR)
	$(MAKE) -C $(LIBSSH2_DIR) clean
	rm -f $(LIBSSH2_DIR)/.configure

srcclean: clean
	rm -rf $(LIBSSH2_DIR)
