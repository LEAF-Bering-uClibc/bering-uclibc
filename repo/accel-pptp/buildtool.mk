# makefile for accel-pptp
include $(MASTERMAKEFILE)

PPTP_DIR:=accel-pptp-0.8.5
PPTP_TARGET_DIR:=$(BT_BUILD_DIR)/accel-pptp
BT_KERNEL_SOURCE:=$(BT_SOURCE_DIR)/linux/linux

export PPPD_VER=2.4.5

$(PPTP_DIR)/.source:
	bzcat $(PPTP_SOURCE) | tar -xvf -
	cat $(PPTP_PATCH1) | patch -p1 -d $(PPTP_DIR)
	touch $(PPTP_DIR)/.source

source: $(PPTP_DIR)/.source

$(PPTP_DIR)/.configured: $(PPTP_DIR)/.source
	(cd $(PPTP_DIR)/pptpd-1.3.3; libtoolize && autoreconf && KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) \
	sh ./configure --prefix=/usr --enable-bcrelay --with-libwrap --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	(cd $(PPTP_DIR)/pppd_plugin; libtoolize && autoreconf && KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) \
	sh ./configure --prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	touch $(PPTP_DIR)/.configured

$(PPTP_DIR)/.build: $(PPTP_DIR)/.configured
	mkdir -p $(PPTP_TARGET_DIR)/usr/sbin
	mkdir -p $(PPTP_TARGET_DIR)/usr/lib/pppd
	mkdir -p $(PPTP_TARGET_DIR)/usr/lib/pptpd
	mkdir -p $(PPTP_TARGET_DIR)/etc/ppp
	mkdir -p $(PPTP_TARGET_DIR)/etc/init.d
	mkdir -p $(PPTP_TARGET_DIR)/etc/modules.d

	(cd $(PPTP_DIR)/kernel/driver && for i in $(KARCHS); do export LOCALVERSION="-$$i" ; \
	mkdir -p $(PPTP_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/net ; \
	$(MAKE) $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) clean && \
	$(MAKE) $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) && \
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) pptp.ko && gzip -9 -f pptp.ko && \
	cp -a pptp.ko.gz $(PPTP_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/net ||\
	exit 1 ; done)

	$(MAKE) -C $(PPTP_DIR)/pptpd-1.3.3 $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) CC=$(TARGET_CC)
	$(MAKE) -C $(PPTP_DIR)/pppd_plugin $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) CC=$(TARGET_CC)
	cp -a $(PPTP_DIR)/pptpd-1.3.3/pptpd $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_DIR)/pptpd-1.3.3/pptpctrl $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_DIR)/pptpd-1.3.3/bcrelay $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_DIR)/pppd_plugin/src/.libs/pptp.so.0.0.0 $(PPTP_TARGET_DIR)/usr/lib/pppd/pptp.so
	cp -a $(PPTP_DIR)/pptpd-1.3.3/plugins/*.so $(PPTP_TARGET_DIR)/usr/lib/pptpd
	cp -aL pptpd.conf $(PPTP_TARGET_DIR)/etc
	cp -a $(PPTP_DIR)/example/etc/ppp/options.pptpd $(PPTP_TARGET_DIR)/etc/ppp
	cp -a $(PPTP_DIR)/example/etc/ppp/options.pptp $(PPTP_TARGET_DIR)/etc/ppp
	cp -aL pptpd $(PPTP_TARGET_DIR)/etc/init.d
	cp -aL accel-pptp.modules $(PPTP_TARGET_DIR)/etc/modules.d/accel-pptp
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPTP_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPTP_TARGET_DIR)/usr/lib/pppd/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPTP_TARGET_DIR)/usr/lib/pptpd/*
	cp -a $(PPTP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PPTP_DIR)/.build

build: $(PPTP_DIR)/.build

clean:
	rm -rf $(PPTP_TARGET_DIR)
	$(MAKE) -C $(PPTP_DIR) clean
	rm -f $(PPTP_DIR)/.build

srcclean: clean
	rm -rf $(PPTP_DIR)
	rm -f $(PPTP_DIR)/.source
