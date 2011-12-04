#############################################################
#
# SAMBA
#
#############################################################

include $(MASTERMAKEFILE)

SAMBA_DIR:=samba-2.0.10
SAMBA_TARGET_DIR:=$(BT_BUILD_DIR)/samba
export CC=$(TARGET_CC)
export LD=$(TARGET_LD)

EXTCFLAGS=-Duint32=uint32_t -Dint32=int32_t
export CFLAGS += $(EXTCFLAGS)

DEFS =	samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
	samba_cv_HAVE_UNSIGNED_CHAR=yes \
	samba_cv_have_longlong=yes \
	samba_cv_HAVE_SHARED_MMAP=yes \
	samba_cv_HAVE_FCNTL_LOCK=yes \
	samba_cv_HAVE_FNMATCH=yes \
	samba_cv_HAVE_IFACE_IFCONF=yes \
	samba_cv_SIZEOF_INO_T=yes \
	samba_cv_SIZEOF_OFF_T=yes \
	samba_cv_USE_SETRESUID=yes \
	samba_cv_have_setresgid=yes \
	samba_cv_have_setresuid=yes

BVARS = BASEDIR=/usr \
	LIBDIR=/etc/samba \
	SMB_PASSWD_FILE=/etc/samba/smbpasswd \
	SMBLOGFILE=/var/log/smb NMBLOGFILE=/var/log/nmb

$(SAMBA_DIR)/.source:
	zcat $(SAMBA_SOURCE) | tar -xvf -
	zcat $(SAMBA_PATCH1) | patch -d $(SAMBA_DIR) -p1
	zcat $(SAMBA_PATCH2) | patch -d $(SAMBA_DIR) -p1
	zcat $(BT_TOOLS_DIR)/config.sub.gz > $(SAMBA_DIR)/source/config.sub
	touch $(SAMBA_DIR)/.source

$(SAMBA_DIR)/.configured: $(SAMBA_DIR)/.source
	(cd $(SAMBA_DIR)/source ; $(DEFS) \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--with-privatedir=/etc/samba \
		--localstatedir=/var \
		--with-lockdir=/var/run \
		--without-smbmount );
	touch $(SAMBA_DIR)/.configured

source: $(SAMBA_DIR)/.source

build: $(SAMBA_DIR)/.configured
	-mkdir -p $(SAMBA_TARGET_DIR)
	-mkdir -p $(SAMBA_TARGET_DIR)/etc/cron.weekly
	-mkdir -p $(SAMBA_TARGET_DIR)/etc/init.d
	-mkdir -p $(SAMBA_TARGET_DIR)/usr/sbin

#hack to build host binaries
	make -C $(SAMBA_DIR)/source clean
	make $(MAKEOPTS) CC=gcc CFLAGS="$(EXTCFLAGS)" -C $(SAMBA_DIR)/source \
	    bin/make_smbcodepage bin/make_unicodemap bin/make_printerdef

	$(SAMBA_DIR)/source/script/installcp.sh \
	$(SAMBA_DIR)/source \
	$(SAMBA_TARGET_DIR)/etc/samba \
	$(SAMBA_TARGET_DIR)/etc/samba/codepages \
	$(SAMBA_DIR)/source/bin \
	850 866 1251

	make -C $(SAMBA_DIR)/source clean
	make $(MAKEOPTS) -C $(SAMBA_DIR)/source all
	cp -a $(SAMBA_DIR)/source/bin/smbd $(SAMBA_TARGET_DIR)/usr/sbin
	cp -a $(SAMBA_DIR)/source/bin/nmbd $(SAMBA_TARGET_DIR)/usr/sbin
	cp -a $(SAMBA_DIR)/source/bin/smbpasswd $(SAMBA_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/sbin/*
	cp -aL samba.init $(SAMBA_TARGET_DIR)/etc/init.d/samba
	cp -aL samba.cron $(SAMBA_TARGET_DIR)/etc/cron.weekly/samba
	cp -aL smb.conf $(SAMBA_TARGET_DIR)/etc/samba
	cp -a $(SAMBA_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SAMBA_DIR)/.build

clean:
	-make -C $(SAMBA_DIR) clean
	rm -rf $(SAMBA_TARGET_DIR)
	rm -f $(SAMBA_DIR)/.build
	rm -f $(SAMBA_DIR)/.configured

srcclean:
	rm -rf $(SAMBA_DIR)

