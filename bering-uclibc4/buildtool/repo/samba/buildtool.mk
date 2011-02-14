#############################################################
#
# SAMBA 
#
#############################################################

include $(MASTERMAKEFILE)

SAMBA_DIR:=samba-2.0.10
SAMBA_TARGET_DIR:=$(BT_BUILD_DIR)/samba
export AUTOCONF=$(BT_STAGING_DIR)/bin/autoconf


BVARS = BASEDIR=/usr \
	LIBDIR=/etc/samba \
	SMB_PASSWD_FILE=/etc/samba/smbpasswd \
	SMBLOGFILE=/var/log/smb NMBLOGFILE=/var/log/nmb

$(SAMBA_DIR)/.source:
	zcat $(SAMBA_SOURCE) | tar -xvf -
	zcat $(SAMBA_PATCH1) | patch -d $(SAMBA_DIR) -p1
	zcat $(SAMBA_PATCH2) | patch -d $(SAMBA_DIR) -p1
	touch $(SAMBA_DIR)/.source
	
$(SAMBA_DIR)/.configured: $(SAMBA_DIR)/.source
	(cd $(SAMBA_DIR)/source ; $(AUTOCONF) ; CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) LD=$(TARGET_LD) \
		./configure \
		--host=$(ARCH)-linux \
		--build=$(ARCH)-linux \
		--target=$(ARCH)-linux \
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

	make -C $(SAMBA_DIR)/source $(BVARS) all

	$(SAMBA_DIR)/source/script/installcp.sh \
	$(SAMBA_DIR)/source \
	$(SAMBA_TARGET_DIR)/etc/samba \
	$(SAMBA_TARGET_DIR)/etc/samba/codepages \
	$(SAMBA_DIR)/source/bin \
	850

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_DIR)/source/bin/smbd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_DIR)/source/bin/nmbd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SAMBA_DIR)/source/bin/smbpasswd
	cp -aL samba.init $(SAMBA_TARGET_DIR)/etc/init.d/samba
	cp -aL samba.cron $(SAMBA_TARGET_DIR)/etc/cron.weekly/samba
	cp -aL smb.conf $(SAMBA_TARGET_DIR)/etc/samba
	cp -a $(SAMBA_DIR)/source/bin/smbd $(SAMBA_TARGET_DIR)/usr/sbin 
	cp -a $(SAMBA_DIR)/source/bin/nmbd $(SAMBA_TARGET_DIR)/usr/sbin 
	cp -a $(SAMBA_DIR)/source/bin/smbpasswd $(SAMBA_TARGET_DIR)/usr/sbin 
	cp -a $(SAMBA_TARGET_DIR)/* $(BT_STAGING_DIR)	
	touch $(SAMBA_DIR)/.build	

clean:
	-make -C $(SAMBA_DIR) clean
	rm -rf $(SAMBA_TARGET_DIR)
	rm -f $(SAMBA_DIR)/.build
	rm -f $(SAMBA_DIR)/.configured
	
srcclean:
	rm -rf $(SAMBA_DIR)
	
