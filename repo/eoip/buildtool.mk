#############################################################
#
# buildtool makefile for eoip
#
#############################################################

DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/eoip

# Option settings for 'configure':
#   Move installed files out from under /usr/local/
#   Include support for SSH2 protocol
#   Disable inclusion of full man page text
#   Disable use of OpenLDAP client library, if present
#   Disable generation of C code
CONFOPTS:= --host=$(GNU_TARGET_NAME) \
	 --build=$(GNU_BUILD_NAME) \
	 --with-sysroot=$(BT_STAGING_DIR) \
	 --prefix=/usr

export CFLAGS=$(ARCH_CFLAGS) -O2
export CPPFLAGS=-I$(BT_STAGING_DIR)/usr/include

.source:
	$(BT_SETUP_BUILDDIR) -v $(SOURCE)
	touch .source

source: .source

.configure: .source
	( cd $(DIR) ; ./configure $(CONFOPTS) )
	touch .configure

build: .configure
	mkdir -p $(TARGET_DIR)/etc/default
	mkdir -p $(TARGET_DIR)/etc/init.d
	$(MAKE) $(MAKEOPTS) -C $(DIR) 
	$(MAKE) -C $(DIR) DESTDIR=$(TARGET_DIR) install
	cp -f $(DIR)/*.cfg $(TARGET_DIR)/etc/
	cp -aL eoip.init $(TARGET_DIR)/etc/init.d/eoip
	cp -aL vip.init $(TARGET_DIR)/etc/init.d/vip
	cp -aL eoip.default $(TARGET_DIR)/etc/default/eoip
	cp -aL vip.default $(TARGET_DIR)/etc/default/vip
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	cp -a -f $(TARGET_DIR)/* $(BT_STAGING_DIR)/

clean:
	rm -rf $(TARGET_DIR)
	$(MAKE) -C $(DIR) clean
	rm -f .configure

srcclean: clean
	rm -rf $(DIR)
	rm -f .source
