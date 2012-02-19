#############################################################
#
# avahi
#
#############################################################

include $(MASTERMAKEFILE)

AVAHI_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(AVAHI_DIR),)
AVAHI_DIR:=$(shell cat DIRNAME)
endif

AVAHI_TARGET_DIR:=$(BT_BUILD_DIR)/avahi

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
#   But keep config files in /etc (rather than /usr/etc)
#   And keep state files in /var (rather than /usr/var)
#   Run as User "lrp" and Group "users" (rather than "avahi", or "root")
#   Disable lots of options not relevant for Bering-uClibc
CONFOPTS:=--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
	--with-avahi-user=lrp --with-avahi-group=users --with-distro=debian \
	--disable-nls --disable-glib --disable-gobject \
	--disable-qt3 --disable-qt4 --disable-gtk --disable-gtk3 \
	--disable-dbus --disable-gdbm --disable-python \
	--disable-mono --disable-monodoc --disable-doxygen-doc \
	--disable-ssp --disable-stack-protector

# Next line is required to locate the .pc file for libdaemon
export PKG_CONFIG_PATH=$(BT_STAGING_DIR)/usr/lib/pkgconfig

.source:
	zcat $(SOURCE) | tar -xvf - 	
	echo $(AVAHI_DIR) > DIRNAME
	touch .source

.configure: .source
	# Need to hack out a big chunk of "configure" which relates to
	# intltool and .po files which we don't need (and doesn't work).
	# First line to delete is #18787:
	#    case "$am__api_version
	# Last line to delete is #19285:
	#    # Substitute ALL_LINGUAS so we can use it in po/Makefile
	( cd $(AVAHI_DIR); sed -i '18787,19285d' configure )
	# Run edited configure script
	( cd $(AVAHI_DIR); ./configure $(CONFOPTS) );
	touch .configure
	
source: .source


.build: .configure
	# Need to remove "po/" from list of SUBDIRS to build
	( cd $(AVAHI_DIR) ; perl -i -p -e 's/	po/ /' Makefile )
	mkdir -p $(AVAHI_TARGET_DIR)
	$(MAKE) -C $(AVAHI_DIR)
	$(MAKE) DESTDIR=$(AVAHI_TARGET_DIR) -C $(AVAHI_DIR) install
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(AVAHI_TARGET_DIR)/usr/sbin/*
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(AVAHI_TARGET_DIR)/usr/lib/*.so
	cp -a $(AVAHI_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin
	cp -ar $(AVAHI_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
	cp -ar $(AVAHI_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
	cp -ar $(AVAHI_TARGET_DIR)/etc/avahi/ $(BT_STAGING_DIR)/etc
	cp -a leaf.service $(BT_STAGING_DIR)/etc/avahi/services/
	cp -a avahi-daemon.init $(BT_STAGING_DIR)/etc/init.d/avahi-daemon
	touch .build

build: .build

clean:
	-$(MAKE) -C $(AVAHI_DIR) clean
	-rm -rf $(AVAHI_TARGET_DIR)
	-rm .build
	
srcclean:
	-rm -rf $(AVAHI_DIR)
	rm DIRNAME

