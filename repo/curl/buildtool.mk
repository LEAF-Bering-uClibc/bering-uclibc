#############################################################
#
# buildtool makefile for curl
#
#############################################################


CURL_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(CURL_SOURCE) 2>/dev/null )
CURL_TARGET_DIR:=$(BT_BUILD_DIR)/curl

# Option settings for 'configure':
#   Move installed files out from under /usr/local/
#   Include support for SSH2 protocol
#   Disable inclusion of full man page text
#   Disable use of OpenLDAP client library, if present
#   Disable generation of C code
CONFOPTS:= --host=$(GNU_TARGET_NAME) \
	 --with-sysroot=$(BT_STAGING_DIR) \
	 --prefix=/usr --with-libssh2 --disable-manual --disable-ldap --disable-libcurl-option

export LDFLAGS += $(EXTCCLDFLAGS)

.source:
	zcat $(CURL_SOURCE) | tar -xvf -
	touch .source

source: .source

.configure: .source
	( cd $(CURL_DIR) ; ./configure $(CONFOPTS) )
	touch .configure

build: .configure
	mkdir -p $(CURL_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(CURL_DIR) 
	$(MAKE) -C $(CURL_DIR) DESTDIR=$(CURL_TARGET_DIR) install
#
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(CURL_TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(CURL_TARGET_DIR)/usr/bin/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(CURL_TARGET_DIR)/usr/lib/*.la
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(CURL_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(CURL_TARGET_DIR)/usr/share
	cp -a -f $(CURL_TARGET_DIR)/* $(BT_STAGING_DIR)/

clean:
	rm -rf $(CURL_TARGET_DIR)
	$(MAKE) -C $(CURL_DIR) clean
	rm -f .configure

srcclean: clean
	rm -rf $(CURL_DIR)
	rm -f .source
