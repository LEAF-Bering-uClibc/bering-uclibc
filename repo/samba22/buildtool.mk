#############################################################
#
# SAMBA
#
#############################################################

include $(MASTERMAKEFILE)

SAMBA_DIR:=samba-2.2.12
SAMBA_TARGET_DIR:=$(BT_BUILD_DIR)/samba22


BVARS = BASEDIR=/usr \
	LIBDIR=/etc/samba \
	SMB_PASSWD_FILE=/etc/samba/smbpasswd

$(SAMBA_DIR)/.source:
	zcat $(SAMBA_SOURCE) | tar -xvf -
	touch $(SAMBA_DIR)/.source

$(SAMBA_DIR)/.configured: $(SAMBA_DIR)/.source
	(cd $(SAMBA_DIR)/source ; libtoolize -i -f && autoconf -f && \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--with-privatedir=/etc/samba \
		--with-piddir=/var/run \
		--localstatedir=/var \
		--with-lockdir=/var/run \
		--with-logfilebase=/var/log \
		--with-codepagedir=/usr/share/samba/codepages \
		--disable-cups \
		--with-utmp \
		--with-included-popt \
		--without-winbind \
		--without-readline \
		--without-smbmount );
	touch $(SAMBA_DIR)/.configured


source: $(SAMBA_DIR)/.source

build: $(SAMBA_DIR)/.configured
	-mkdir -p $(SAMBA_TARGET_DIR)
	-mkdir -p $(SAMBA_TARGET_DIR)/etc/cron.weekly
	-mkdir -p $(SAMBA_TARGET_DIR)/etc/init.d
	-mkdir -p $(SAMBA_TARGET_DIR)/etc/samba
	-mkdir -p $(SAMBA_TARGET_DIR)/usr/sbin
	-mkdir -p $(SAMBA_TARGET_DIR)/usr/share/samba

	make $(MAKEOPTS) -C $(SAMBA_DIR)/source $(BVARS) all

	$(SAMBA_DIR)/source/script/installcp.sh \
	$(SAMBA_DIR)/source \
	$(SAMBA_TARGET_DIR)/usr/share/samba \
	$(SAMBA_TARGET_DIR)/usr/share/samba/codepages \
	$(SAMBA_DIR)/source/bin \
	850 ISO8859-1 866 1251

	cp -aL samba.init $(SAMBA_TARGET_DIR)/etc/init.d/samba22
	cp -aL samba.cron $(SAMBA_TARGET_DIR)/etc/cron.weekly/samba22
	cp -aL smb.conf $(SAMBA_TARGET_DIR)/etc/samba/smb.conf22
	cp -a $(SAMBA_DIR)/source/bin/smbd $(SAMBA_TARGET_DIR)/usr/sbin/smbd22
	cp -a $(SAMBA_DIR)/source/bin/nmbd $(SAMBA_TARGET_DIR)/usr/sbin/nmbd22
	cp -a $(SAMBA_DIR)/source/bin/smbpasswd $(SAMBA_TARGET_DIR)/usr/sbin/smbpasswd22
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_TARGET_DIR)/usr/sbin/*
	cp -a $(SAMBA_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SAMBA_DIR)/.build

clean:
	-make -C $(SAMBA_DIR) clean
	rm -rf $(SAMBA_TARGET_DIR)
	rm -f $(SAMBA_DIR)/.build
	rm -f $(SAMBA_DIR)/.configured

srcclean:
	rm -rf $(SAMBA_DIR)

