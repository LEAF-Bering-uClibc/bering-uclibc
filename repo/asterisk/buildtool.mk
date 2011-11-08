#############################################################
#
# buildtool makefile for asterisk
#
#############################################################

include $(MASTERMAKEFILE)

ASTERISK_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(ASTERISK_DIR),)
ASTERISK_DIR:=$(shell cat DIRNAME)
endif
ASTERISK_TARGET_DIR:=$(BT_BUILD_DIR)/asterisk

# Option settings for 'configure':
#   Move files out from under /usr/local/
#   Disable generation of XML documentation
CONFOPTS:=--host=i486-pc-linux-gnu \
	--prefix=/usr --disable-xmldoc --without-sdl
# --enable-dev-mode

.source:
	zcat $(SOURCE) | tar -xvf -
	echo $(ASTERISK_DIR) > DIRNAME
	touch .source

source: .source

.configure: .source
	( cd $(ASTERISK_DIR) ; ./configure $(CONFOPTS) )
	touch .configure

build: .configure
	mkdir -p $(ASTERISK_TARGET_DIR)
	$(MAKE) -C $(ASTERISK_DIR) \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		OPTIONS="-DLOW_MEMORY" \
		DESTDIR=$(ASTERISK_TARGET_DIR) install samples
#
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ASTERISK_TARGET_DIR)/usr/lib/asterisk/modules/*.so
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ASTERISK_TARGET_DIR)/usr/sbin/asterisk
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ASTERISK_TARGET_DIR)/usr/sbin/astcanary
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
	-rm DIRNAME

