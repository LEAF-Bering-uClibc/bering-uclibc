#############################################################
#
# buildtool makefile for netatalk 
#
#############################################################

include $(MASTERMAKEFILE)

SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
ifeq ($(SOURCE_DIR),)
SOURCE_DIR:=$(shell cat DIRNAME)
endif
TARGET_DIR:=$(BT_BUILD_DIR)/netatalk

# Variable definitions for 'configure'
#  Yes, we have a working avahi client library
#  TODO Move to MasterInclude.mk ?
CONFDEFS = ac_cv_lib_avahi_client_avahi_client_new=yes

# Option settings for 'configure'
#  Need to specify location of Berkeley DB installation
#  Need to specify location of OpenSSL installation
#  Need to specify location of GnuPG libgcrypt installation
#  Need to specify location of sysroot
#  Move files out from under /usr/local/ but use /etc rather than /usr/etc
#  Enable Zeroconf support (avahi)
#  Select Debian-style target
CONFOPTS = \
	--with-bdb=$(BT_STAGING_DIR)/usr \
	--with-ssl-dir=$(BT_STAGING_DIR)/usr \
	--with-libgcrypt-dir=$(BT_STAGING_DIR)/usr \
	--with-sysroot=$(BT_STAGING_DIR) \
	--prefix=/usr --sysconfdir=/etc \
	--enable-zeroconf \
	--enable-debian \
--without-gssapi \
--without-ldap

.source:
	bzcat $(SOURCE_TGZ) | tar -xvf -
	echo $(SOURCE_DIR) > DIRNAME
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR) ; $(CONFDEFS) ./configure $(CONFOPTS) )
	# Crude hack to tolerate references to build host /usr/lib
	( cd $(SOURCE_DIR); sed -i '6060s,exit.*,continue,' libtool )
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/etc/default
	mkdir -p $(BT_STAGING_DIR)/etc/netatalk/uams
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/usr/bin

	make CC="$(TARGET_CC) -std=gnu99" LD=$(TARGET_LD) -C $(SOURCE_DIR)
	make -C $(SOURCE_DIR) DESTDIR=$(TARGET_DIR) install

	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/etc/netatalk/uams/*.so
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	cp -a $(TARGET_DIR)/etc/netatalk/uams/*.so $(BT_STAGING_DIR)/etc/netatalk/uams/
	cp -a $(TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin/
	cp -a $(TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/etc/default/netatalk $(BT_STAGING_DIR)/etc/default/
	cp -a $(TARGET_DIR)/etc/netatalk/afpd.conf $(BT_STAGING_DIR)/etc/netatalk/
	cp -a $(TARGET_DIR)/etc/netatalk/AppleVolumes.system $(BT_STAGING_DIR)/etc/netatalk/
	cp -a $(TARGET_DIR)/etc/netatalk/AppleVolumes.default $(BT_STAGING_DIR)/etc/netatalk/
	cp -aL netatalk.init $(BT_STAGING_DIR)/etc/init.d/netatalk
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
