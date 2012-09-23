#############################################################
#
# buildtool makefile for asterisk
#
#############################################################


ASTERISK_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ASTERISK_TARGET_DIR:=$(BT_BUILD_DIR)/asterisk

# Option settings for 'configure':
#   Move files out from under /usr/local/
#   Disable generation of XML documentation
CONFOPTS:= --prefix=/usr --disable-xmldoc --without-sdl
# --enable-dev-mode

unexport CFLAGS CPPFLAGS

.source:
	zcat $(SOURCE) | tar -xvf -
	perl -i -p -e 's,\&\&\s+\./configure, ,' $(ASTERISK_DIR)/configure $(ASTERISK_DIR)/configure.ac
	touch .source

source: .source

.configure: .source
	( cd $(ASTERISK_DIR) ; CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" \
	    ./configure $(CONFOPTS) --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	( cd $(ASTERISK_DIR)/menuselect ; ./configure $(CONFOPTS) )
	# Force linking of asterisk executable against -lpthread
	perl -i -p -e 's,GMIMELDFLAGS\),GMIMELDFLAGS\) -lpthread,' $(ASTERISK_DIR)/main/Makefile
	# 
	perl -i -p -e 's,.*HAVE_RES_NINIT.*,,' $(ASTERISK_DIR)/include/asterisk/autoconfig.h
	touch .configure

build: .configure
	mkdir -p $(ASTERISK_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(ASTERISK_DIR) OPTIONS="-DLOW_MEMORY"
	$(MAKE) -C $(ASTERISK_DIR) DESTDIR=$(ASTERISK_TARGET_DIR) install samples
#
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ASTERISK_TARGET_DIR)/usr/lib/asterisk/modules/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ASTERISK_TARGET_DIR)/usr/sbin/*
	-rm -rf $(ASTERISK_TARGET_DIR)/usr/share
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	cp -L -f asterisk.init $(BT_STAGING_DIR)/etc/init.d/asterisk
	cp -a -f $(ASTERISK_TARGET_DIR)/etc/asterisk $(BT_STAGING_DIR)/etc
	mkdir -p $(BT_STAGING_DIR)/var/lib/asterisk/
	cp -a -f $(ASTERISK_TARGET_DIR)/var/lib/asterisk/sounds $(BT_STAGING_DIR)/var/lib/asterisk
	cp -a -f $(ASTERISK_TARGET_DIR)/var/lib/asterisk/moh $(BT_STAGING_DIR)/var/lib/asterisk
	mkdir -p $(BT_STAGING_DIR)/usr/lib/asterisk/
	cp -a -f $(ASTERISK_TARGET_DIR)/usr/lib/asterisk/modules $(BT_STAGING_DIR)/usr/lib/asterisk
	mkdir -p $(BT_STAGING_DIR)/usr/sbin/
	cp -a -f $(ASTERISK_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/usr/include/
	cp -a -f $(ASTERISK_TARGET_DIR)/usr/include/asterisk $(BT_STAGING_DIR)/usr/include

clean:
	rm -rf $(ASTERISK_TARGET_DIR)
	$(MAKE) -C $(ASTERISK_DIR) clean
	rm -f .configure .build

srcclean: clean
	rm -rf $(ASTERISK_DIR)
	-rm -f .source

