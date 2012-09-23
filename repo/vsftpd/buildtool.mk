#############################################################
#
# vsftpd
#
#############################################################

VSFTPD_DIR:=vsftpd-3.0.0
VSFTPD_TARGET_DIR:=$(BT_BUILD_DIR)/vsftpd


$(VSFTPD_DIR)/.source:
	zcat $(VSFTPD_SOURCE) |  tar -xvf -
	cat $(VSFTPD_PATCH1) | patch -d $(VSFTPD_DIR) -p1
	perl -i -p -e \
		'/^locate_library\(\).*/ && s,\$$,$(BT_STAGING_DIR)\$$,g' \
		$(VSFTPD_DIR)/vsf_findlibs.sh
	touch $(VSFTPD_DIR)/.source

$(VSFTPD_DIR)/.build:
	mkdir -p $(VSFTPD_TARGET_DIR)
	mkdir -p $(VSFTPD_TARGET_DIR)/usr/sbin
	mkdir -p $(VSFTPD_TARGET_DIR)/etc/init.d
	mkdir -p $(VSFTPD_TARGET_DIR)/etc/cron.daily
	$(MAKE) $(MAKEOPTS) -C $(VSFTPD_DIR) CC=$(TARGET_CC) LDFLAGS="-fPIE -pie -Wl,-z,relro -Wl,-z,now  $(LDFLAGS)" CFLAGS="-Wall -W -Wshadow $(CFLAGS)" LINK=
	cp -a $(VSFTPD_DIR)/vsftpd $(VSFTPD_TARGET_DIR)/usr/sbin/
	cp -aL vsftpd.init $(VSFTPD_TARGET_DIR)/etc/init.d/vsftpd
	cp -aL vsftpd.conf $(VSFTPD_TARGET_DIR)/etc/
	cp -aL vsftpd.cron $(VSFTPD_TARGET_DIR)/etc/cron.daily/vsftpd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(VSFTPD_TARGET_DIR)/usr/sbin/*
	cp -a $(VSFTPD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(VSFTPD_DIR)/.build

source: $(VSFTPD_DIR)/.source

build: $(VSFTPD_DIR)/.build

clean:
	-rm $(VSFTPD_DIR)/.build
	$(MAKE) -C $(VSFTPD_DIR) clean

srcclean:
	rm -rf $(VSFTPD_DIR)
