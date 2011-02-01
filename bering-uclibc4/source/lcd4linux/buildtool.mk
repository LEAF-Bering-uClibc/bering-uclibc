#############################################################
#
# lcd4linux
#
#############################################################

include $(MASTERMAKEFILE)
LCD4LINUX_DIR:=lcd4linux-0.10.1-RC1
LCD4LINUX_TARGET_DIR:=$(BT_BUILD_DIR)/lcd4linux


$(LCD4LINUX_DIR)/.source:
	zcat $(LCD4LINUX_SOURCE) |  tar -xvf - 
	zcat $(LCD4LINUX_PATCH1) |  patch -p1 -d $(LCD4LINUX_DIR)
	touch $(LCD4LINUX_DIR)/.source

$(LCD4LINUX_DIR)/.configured: $(LCD4LINUX_DIR)/.source
	#rm -f $(LCD4LINUX_DIR)/aclocal.m4
	#rm -rf $(LCD4LINUX_DIR)/autom4te.cache
	#rm -f $(LCD4LINUX_DIR)/config.cache
	#(cd $(LCD4LINUX_DIR); ./bootstrap );

	(cd $(LCD4LINUX_DIR); rm -f config.cache acconfig.h; \
		aclocal-1.4 ; autoconf; autoheader; automake -a)
	(cd $(LCD4LINUX_DIR); CC=$(TARGET_CC)  CFLAGS="$(BT_COPT_FLAGS)" \
	./configure \
		--prefix=/usr/ \
		--with-dmalloc=no \
		--disable-dependency-tracking \
		--disable-shared \
		--disable-static \
		--with-gnu-ld \
		--without-ncurses \
		--without-osf1-curses \
		--without-sco \
		--without-sunos-curses \
		--without-vcurses \
		--without-x \
		--without-python \
		--without-libiconv-prefix \
		--with-drivers=all,!Curses,!G15,!LCDLinux,!LCD2USB,!USBHUB,!USBLCD,!picoLCD,!NULL,!PNG,!PPM,!LUIse,!serdisplib,!BWCT,!Trefon,!X11 \
		--with-plugins=all,!mysql,!dvb,!xmms,!seti,!mpd );

	echo "#define DONT_HAVE_ROUND 1" >> $(LCD4LINUX_DIR)/config.h
	touch $(LCD4LINUX_DIR)/.configured

source: $(LCD4LINUX_DIR)/.source
	
$(LCD4LINUX_DIR)/.build: $(LCD4LINUX_DIR)/.configured
	-mkdir $(LCD4LINUX_TARGET_DIR)
	-mkdir -p $(LCD4LINUX_TARGET_DIR)/etc/init.d 
	-mkdir -p $(BT_STAGING_DIR)/etc/init.d
	-mkdir -p $(BT_STAGING_DIR)/usr/sbin
	$(MAKE) CC=$(TARGET_CC) -C $(LCD4LINUX_DIR) lcd4linux
	perl -i -p -e 's,DESTDIR =.*,DESTDIR =$(LCD4LINUX_TARGET_DIR),' $(LCD4LINUX_DIR)/Makefile
	$(MAKE) DESTDIR=$(LCD4LINUX_TARGET_DIR) CC=$(TARGET_CC) -C $(LCD4LINUX_DIR) install
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LCD4LINUX_TARGET_DIR)/usr/bin/lcd4linux
	-cp lcd4linux.conf $(LCD4LINUX_TARGET_DIR)/etc/ 
	-cp $(LCD4LINUX_TARGET_DIR)/etc/lcd4linux.conf $(BT_STAGING_DIR)/etc/ 
	-cp $(LCD4LINUX_TARGET_DIR)/usr/bin/lcd4linux* $(BT_STAGING_DIR)/usr/sbin/
	-cp lcd4linux.init $(LCD4LINUX_TARGET_DIR)/etc/init.d/lcd4linux 
	-cp lcd4linux.init $(BT_STAGING_DIR)/etc/init.d/lcd4linux 
	touch $(LCD4LINUX_DIR)/.build

build: $(LCD4LINUX_DIR)/.build

clean:
	rm -rf $(LCD4LINUX_TARGET_DIR)
	-rm $(LCD4LINUX_DIR)/.build
	-$(MAKE) -C $(LCD4LINUX_DIR) clean
	rm -f $(BT_STAGING_DIR)/etc/lcd4linux.conf
	rm -f $(BT_STAGING_DIR)/usr/sbin/lcd4linux* 
	rm -f $(BT_STAGING_DIR)/etc/init.d/lcd4linux 
	
  
srcclean:
	rm -rf $(LCD4LINUX_DIR)
    
