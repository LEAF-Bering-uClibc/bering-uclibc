#############################################################
#
# iscsi-target
#
#############################################################


ISCSI_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(ISCSI_SOURCE) 2>/dev/null )
ISCSI_TARGET_DIR:=$(BT_BUILD_DIR)/iscsi

export CC=$(TARGET_CC)

source:
	-rm -rf $(ISCSI_DIR)
	zcat $(ISCSI_SOURCE) | tar -xvf -
#	cat $(ISCSI_PATCH1) | patch -d $(ISCSI_DIR) -p0
#	cat $(ISCSI_PATCH2) | patch -d $(ISCSI_DIR) -p0
#	cat $(ISCSI_PATCH3) | patch -d $(ISCSI_DIR) -p1
#	cat $(ISCSI_PATCH4) | patch -d $(ISCSI_DIR) -p0
#	cat $(ISCSI_PATCH5) | patch -d $(ISCSI_DIR) -p1
#	cat $(ISCSI_PATCH6) | patch -d $(ISCSI_DIR) -p0
#	cat $(ISCSI_PATCH7) | patch -d $(ISCSI_DIR) -p0
#	cat $(ISCSI_PATCH8) | patch -d $(ISCSI_DIR) -p1

build:
	mkdir -p $(ISCSI_TARGET_DIR)/usr/sbin
	mkdir -p $(ISCSI_TARGET_DIR)/etc/init.d
	mkdir -p $(ISCSI_TARGET_DIR)/etc/modules.d
	$(MAKE) $(MAKEOPTS) -C $(ISCSI_DIR) usr
	(for i in $(KARCHS); do \
	mkdir -p $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/iscsi && \
	$(MAKE) $(MAKEOPTS) KSRC=$(BT_LINUX_DIR)-$$i -C $(ISCSI_DIR) unpatch && \
	$(MAKE) $(MAKEOPTS) KSRC=$(BT_LINUX_DIR)-$$i -C $(ISCSI_DIR) kernel && \
	gzip -9 $(ISCSI_DIR)/kernel/iscsi_trgt.ko && \
	cp -a $(ISCSI_DIR)/kernel/iscsi_trgt.ko.gz $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/iscsi && \
	rm -f $(ISCSI_DIR)/kernel/iscsi_trgt.ko.gz && \
	depmod -ae -b $(BT_STAGING_DIR) -r -F $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/build/System.map $(BT_KERNEL_RELEASE)-$$i || exit 1; \
	done)
	cp -a $(ISCSI_DIR)/usr/ietd $(ISCSI_TARGET_DIR)/usr/sbin
	cp -a $(ISCSI_DIR)/usr/ietadm $(ISCSI_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ISCSI_TARGET_DIR)/usr/sbin/*
	cp -a $(ISCSI_DIR)/etc/*.* $(ISCSI_TARGET_DIR)/etc
	cp -aL iscsi-target.init $(ISCSI_TARGET_DIR)/etc/init.d/iscsi-target
	cp -aL iscsid.modules $(ISCSI_TARGET_DIR)/etc/modules.d
	cp -a $(ISCSI_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	$(MAKE) KSRC=$(BT_LINUX_DIR)$(FIRSTKARCH) CC=$(TARGET_CC) -C $(ISCSI_DIR) clean
	rm -rf $(BT_BUILD_DIR)/iscsi
	rm -f $(BT_STAGING_DIR)/usr/sbin/ietd
	rm -f $(BT_STAGING_DIR)/usr/sbin/ietadm
	rm -f $(BT_STAGING_DIR)/etc/init.d/iscsi-target
	rm -f $(BT_STAGING_DIR)/etc/ietd.conf
	rm -f $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)/kernel/iscsi/iscsi_trgt.ko.gz
