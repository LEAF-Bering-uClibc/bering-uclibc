# makefile for accel-pptp
include $(MASTERMAKEFILE)

PPTP_DIR:=accel-pptp-0.8.5
PPTP_TARGET_DIR:=$(BT_BUILD_DIR)/accel-pptp
BT_KERNEL_SOURCE:=$(BT_SOURCE_DIR)/linux/linux

$(PPTP_DIR)/.source:
	bzcat $(PPTP_SOURCE) | tar -xvf -
	touch $(PPTP_DIR)/.source

source: $(PPTP_DIR)/.source

$(PPTP_DIR)/.build: 
	mkdir -p $(PPTP_TARGET_DIR)/usr/sbin
	mkdir -p $(PPTP_TARGET_DIR)/usr/lib/pppd
	mkdir -p $(PPTP_TARGET_DIR)/usr/lib/pptpd
	mkdir -p $(PPTP_TARGET_DIR)/etc/ppp
	mkdir -p $(PPTP_TARGET_DIR)/etc/init.d
	mkdir -p $(PPTP_TARGET_DIR)/etc/modules.d
	sed 's:\([="'\'' ]\+\)\(/usr\|/usr/local\)/\(s\)\?bin:\1$(BT_STAGING_DIR)\2/\3bin:g;' \
	$(PPTP_DIR)/pptpd-1.3.3/configure >$(PPTP_DIR)/pptpd-1.3.3/configure.1
	sed 's:\([="'\'' ]\+\)\(/usr\|/usr/local\)/\(s\)\?bin:\1$(BT_STAGING_DIR)\2/\3bin:g;' \
	$(PPTP_DIR)/pppd_plugin/configure >$(PPTP_DIR)/pppd_plugin/configure.1
	sed 's:/usr/src/linux:$(BT_KERNEL_SOURCE):g;' \
	$(PPTP_DIR)/pptpd-1.3.3/configure.1 >$(PPTP_DIR)/pptpd-1.3.3/configure.2
	sed 's:/usr/src/linux:$(BT_KERNEL_SOURCE):g;' \
	$(PPTP_DIR)/pppd_plugin/configure.1 >$(PPTP_DIR)/pppd_plugin/configure.2
	sed 's:which pppd:echo $(BT_STAGING_DIR)/usr/sbin/pppd:g;' \
	$(PPTP_DIR)/pppd_plugin/configure.2 >$(PPTP_DIR)/pppd_plugin/configure.3
	sed 's:which pppd:echo $(BT_STAGING_DIR)/usr/sbin/pppd:g;' \
	$(PPTP_DIR)/pptpd-1.3.3/configure.2 >$(PPTP_DIR)/pptpd-1.3.3/configure.3
	(cd $(PPTP_DIR)/pptpd-1.3.3; KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) \
	sh ./configure.3 --prefix=/usr --enable-bcrelay --with-libwrap)
	(cd $(PPTP_DIR)/pppd_plugin; KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) \
	sh ./configure.3 --prefix=/usr)

	(cd $(PPTP_DIR)/kernel/driver && for i in $(KARCHS); do export LOCALVERSION="-$$i" ; \
	mkdir -p $(PPTP_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/net ; \
	$(MAKE) $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) clean && \
	$(MAKE) $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) && \
	cp -a pptp.ko $(PPTP_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/net ||\
	exit 1 ; done)
	
	sed 's:$(BT_STAGING_DIR)::g;' \
	$(PPTP_DIR)/pptpd-1.3.3/config.h >$(PPTP_DIR)/pptpd-1.3.3/config.h.1
	rm $(PPTP_DIR)/pptpd-1.3.3/config.h && \
	mv $(PPTP_DIR)/pptpd-1.3.3/config.h.1 $(PPTP_DIR)/pptpd-1.3.3/config.h
	$(MAKE) -C $(PPTP_DIR)/pptpd-1.3.3 $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) CC=$(TARGET_CC)
	$(MAKE) -C $(PPTP_DIR)/pppd_plugin $(EXTRA_VARS) KDIR=$(BT_LINUX_DIR)$(FIRSTKARCH) CC=$(TARGET_CC)
	cp -a $(PPTP_DIR)/pptpd-1.3.3/pptpd $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_DIR)/pptpd-1.3.3/pptpctrl $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_DIR)/pptpd-1.3.3/bcrelay $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_DIR)/pppd_plugin/src/.libs/pptp.so.0.0.0 $(PPTP_TARGET_DIR)/usr/lib/pppd/pptp.so
	cp -a $(PPTP_DIR)/pptpd-1.3.3/plugins/*.so $(PPTP_TARGET_DIR)/usr/lib/pptpd
#	cp -a $(PPTP_DIR)/example/etc/pptpd.conf $(PPTP_TARGET_DIR)/etc
	cp -aL pptpd.conf $(PPTP_TARGET_DIR)/etc
	cp -a $(PPTP_DIR)/example/etc/ppp/options.pptpd $(PPTP_TARGET_DIR)/etc/ppp
	cp -a $(PPTP_DIR)/example/etc/ppp/options.pptp $(PPTP_TARGET_DIR)/etc/ppp
	cp -aL pptpd $(PPTP_TARGET_DIR)/etc/init.d
	cp -aL accel-pptp.modules $(PPTP_TARGET_DIR)/etc/modules.d/accel-pptp
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPTP_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PPTP_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)/net/*.ko
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
