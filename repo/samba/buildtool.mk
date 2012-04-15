#############################################################
#
# buildtool makefile for samba 
#
#############################################################

include $(MASTERMAKEFILE)

SAMBA_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SAMBA_SOURCE) 2>/dev/null )
ifeq ($(SAMBA_DIR),)
SAMBA_DIR:=$(shell cat DIRNAME)
endif
SAMBA_TARGET_DIR:=$(BT_BUILD_DIR)/samba

# Variable definitions for 'configure'
CONFDEFS = samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
	ac_cv_file__proc_sys_kernel_core_pattern=no \
	libreplace_cv_HAVE_GETADDRINFO=no

# Option settings for 'configure'
CONFOPTS = --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-fhs \
	--prefix=/usr \
	--with-cachedir=/var/run/samba \
	--with-configdir=/etc/samba \
	--with-lockdir=/var/lock/samba \
	--with-logfilebase=/var/log \
	--with-ncalrpcdir=/var/run/samba \
	--with-nmbdsocketdir=/var/run/samba \
	--with-piddir=/var/run \
	--with-statedir=/etc/samba \
	--with-libsmbclient \
	--with-utmp \
	--disable-cups \
	--disable-avahi \
	--without-ldap \
	--without-ads \
	--without-winbind \
	--without-readline

.source:
	zcat $(SAMBA_SOURCE) | tar -xvf -
	echo $(SAMBA_DIR) > DIRNAME
	touch .source

source: .source

.configured: .source
	( cd $(SAMBA_DIR)/source3 ; $(CONFDEFS) ./configure $(CONFOPTS) )
	touch .configured

build: .configured
	mkdir -p $(SAMBA_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/etc/cron.weekly
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/etc/samba
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/usr/share

	make -C $(SAMBA_DIR)/source3
	make -C $(SAMBA_DIR)/source3 DESTDIR=$(SAMBA_TARGET_DIR) install

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/sbin/nmbd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/sbin/smbd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/sbin/swat
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/testparm
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbpasswd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbstatus
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/tdbbackup
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/nmblookup
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/rpcclient
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/sharesec
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbcacls
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbclient
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbget
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbprint
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbspool
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/smbtree
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/tdbdump
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/tdbrestore
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/pdbedit
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/bin/tdbtool
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(SAMBA_TARGET_DIR)/usr/lib/*.so
	cp -a $(SAMBA_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin/
	cp -a $(SAMBA_TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -a $(SAMBA_TARGET_DIR)/usr/lib/*.so* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(SAMBA_TARGET_DIR)/usr/lib/samba/ $(BT_STAGING_DIR)/usr/lib/
	cp -a $(SAMBA_TARGET_DIR)/usr/share/samba/ $(BT_STAGING_DIR)/usr/share/
	cp -aL samba.init $(BT_STAGING_DIR)/etc/init.d/samba
	cp -aL samba.cron $(BT_STAGING_DIR)/etc/cron.weekly/samba
	cp -aL smb.conf $(BT_STAGING_DIR)/etc/samba/
	touch .build	

clean:
	-make -C $(SAMBA_DIR)/source3 clean
	rm -rf $(SAMBA_TARGET_DIR)
	rm -f .build
	rm -f .configured
	
srcclean:
	rm -rf $(SAMBA_DIR)
	rm .source
	rm DIRNAME
