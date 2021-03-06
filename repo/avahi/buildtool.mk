#############################################################
#
# avahi
#
#############################################################


AVAHI_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
AVAHI_TARGET_DIR:=$(BT_BUILD_DIR)/avahi

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
#   But keep config files in /etc (rather than /usr/etc)
#   And keep state files in /var (rather than /usr/var)
#   Run as User "avahi" and Group "avahi"
#   Disable lots of options not relevant for Bering-uClibc
CONFOPTS:= \
	--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
	--with-avahi-user=avahi --with-avahi-group=avahi --with-distro=debian \
	--disable-nls --disable-glib --disable-gobject \
	--disable-qt3 --disable-qt4 --disable-gtk --disable-gtk3 \
	--disable-gdbm --disable-python --disable-mono --disable-monodoc \
	--disable-doxygen-doc \
	--host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME)

.source:
	zcat $(SOURCE) | tar -xvf -
	touch .source

.configure: .source
	# Need to hack out a big chunk of "configure" which relates to
	# intltool and .po files which we don't need (and doesn't work).
	# First line to delete is #18787:
	#    case "$am__api_version
	# Last line to delete is #19285:
	#    # Substitute ALL_LINGUAS so we can use it in po/Makefile
#	( cd $(AVAHI_DIR); sed -i '18787,19285d' configure )
	# Run edited configure script
	( cd $(AVAHI_DIR); ./configure $(CONFOPTS) );
	touch .configure
	
source: .source


.build: .configure
	# Need to remove "po/" from list of SUBDIRS to build
	#( cd $(AVAHI_DIR) ; perl -i -p -e 's/	po/ /' Makefile )
	# Fix rpath to avoid picking up libraries from build host's /usr/lib
	( cd $(AVAHI_DIR) ; find . -name Makefile -exec perl -i -p -e "s,-rpath \\$$\(libdir\),-rpath $(AVAHI_TARGET_DIR)/usr/lib," {} \; )
	mkdir -p $(AVAHI_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	mkdir -p $(BT_STAGING_DIR)/etc/avahi/services
	mkdir -p $(BT_STAGING_DIR)/etc/dbus-1/system.d/
	$(MAKE) $(MAKEOPTS) -C $(AVAHI_DIR)
	$(MAKE) DESTDIR=$(AVAHI_TARGET_DIR) -C $(AVAHI_DIR) install
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(AVAHI_TARGET_DIR)/usr/sbin/*
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(AVAHI_TARGET_DIR)/usr/lib/*.so
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(AVAHI_TARGET_DIR)/usr/lib/*.la
	# Fix dependency_libs for libtool
	perl -i -p -e "s, /usr/lib/, $(BT_STAGING_DIR)/usr/lib/," $(AVAHI_TARGET_DIR)/usr/lib/*.la
	cp -a $(AVAHI_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin
	cp -ar $(AVAHI_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
	cp -ar $(AVAHI_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
	cp -ar $(AVAHI_TARGET_DIR)/etc/avahi/ $(BT_STAGING_DIR)/etc
	cp -aL leaf.service $(BT_STAGING_DIR)/etc/avahi/services/
	cp -aL avahi-dbus.conf $(BT_STAGING_DIR)/etc/dbus-1/system.d/
	cp -aL avahi-daemon.init $(BT_STAGING_DIR)/etc/init.d/avahi-daemon
	touch .build

build: .build

clean:
	-$(MAKE) -C $(AVAHI_DIR) clean
	-rm -rf $(AVAHI_TARGET_DIR)
	-rm .build
	
srcclean:
	-rm -rf $(AVAHI_DIR)
	-rm -rf .source
	-rm -rf .configure
