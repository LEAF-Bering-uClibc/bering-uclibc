#############################################################
#
# buildtool makefile for dbus 
#
#############################################################

include $(MASTERMAKEFILE)

SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
ifeq ($(SOURCE_DIR),)
SOURCE_DIR:=$(shell cat DIRNAME)
endif
TARGET_DIR:=$(BT_BUILD_DIR)/dbus

# Option settings for 'configure'
#  Move files out from under /usr/local/ but use /etc and /var
#  Specify location of sysroot
#  Use account 'dbus', shorter than the default 'messagebus'
#  Omit initscripts (no option for Debian, only RedHat etc.)
#  Don't attempt to use X Window System or SELinux
#  Don't bother with documentation
CONFOPTS = \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
	--with-sysroot=$(BT_STAGING_DIR) \
	--with-dbus-user=dbus \
	--with-init-scripts=none \
	--without-x --disable-selinux \
	--disable-xml-docs --disable-doxygen-docs

.source:
	zcat $(SOURCE_TGZ) | tar -xvf -
	echo $(SOURCE_DIR) > DIRNAME
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR) ; ./configure $(CONFOPTS) )
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	mkdir -p $(BT_STAGING_DIR)/etc/dbus-1
	mkdir -p $(BT_STAGING_DIR)/etc/init.d

	make -C $(SOURCE_DIR)
	# Need to tweak pkgconfig paths before "make install"
	perl -i -p -e "s,^includedir.*,includedir=$(BT_STAGING_DIR)/usr/include," $(SOURCE_DIR)/dbus-1.pc
	perl -i -p -e "s,^libdir.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(SOURCE_DIR)/dbus-1.pc
	make -C $(SOURCE_DIR) DESTDIR=$(TARGET_DIR) install
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(TARGET_DIR)/usr/lib/libdbus-1.la

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
	cp -a $(TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	cp -a $(TARGET_DIR)/etc/dbus-1/*.conf $(BT_STAGING_DIR)/etc/dbus-1/
	cp -aL messagebus.init $(BT_STAGING_DIR)/etc/init.d/messagebus
	rm -f $(BT_STAGING_DIR)/etc/machine-id
	touch $(BT_STAGING_DIR)/etc/machine-id
	touch .build	

clean:
	-make -C $(SOURCE_DIR) clean
	rm -rf $(TARGET_DIR)
	rm -f .build
	rm -f .configured
	
srcclean:
	rm -rf $(SOURCE_DIR)
	rm .source
	rm DIRNAME
