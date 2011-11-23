#############################################################
#
# buildtool makefile for curl
#
#############################################################

include $(MASTERMAKEFILE)

CURL_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(CURL_SOURCE) 2>/dev/null )
ifeq ($(CURL_DIR),)
CURL_DIR:=$(shell cat DIRNAME)
endif
CURL_TARGET_DIR:=$(BT_BUILD_DIR)/curl

# Option settings for 'configure':
#   Move installed files out from under /usr/local/
#   Include support for SSH2 protocol
#   Disable inclusion of full man page text
#   Disable use of OpenLDAP client library, if present
CONFOPTS:= --build=$(GNU_TARGET_NAME) --host=$(GNU_HOST_NAME) \
	--prefix=/usr --with-libssh2 --disable-manual --disable-ldap

.source:
	zcat $(CURL_SOURCE) | tar -xvf -
	echo $(CURL_DIR) > DIRNAME
	touch .source

source: .source

.configure: .source
	( cd $(CURL_DIR) ; ./configure $(CONFOPTS) )
	touch .configure

build: .configure
	mkdir -p $(CURL_TARGET_DIR)
	$(MAKE) -C $(CURL_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD)
	$(MAKE) -C $(CURL_DIR) DESTDIR=$(CURL_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(CURL_TARGET_DIR)/usr/lib/libcurl.so
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(CURL_TARGET_DIR)/usr/bin/curl
	cp -a -f $(CURL_TARGET_DIR)/usr/lib/libcurl* $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/lib/pkgconfig
	cp -a -f $(CURL_TARGET_DIR)/usr/lib/pkgconfig/libcurl.pc $(BT_STAGING_DIR)/usr/lib/pkgconfig/
	mkdir -p $(BT_STAGING_DIR)/usr/include/curl
	cp -a -f $(CURL_TARGET_DIR)/usr/include/curl/* $(BT_STAGING_DIR)/usr/include/curl/
	cp -a -f $(CURL_TARGET_DIR)/usr/bin/curl* $(BT_STAGING_DIR)/usr/bin

clean:
	rm -rf $(CURL_TARGET_DIR)
	$(MAKE) -C $(CURL_DIR) clean
	rm -f .configure

srcclean: clean
	rm -rf $(CURL_DIR)
	rm -f .source
	-rm DIRNAME

