#############################################################
#
# iscsi-target
#
#############################################################

include $(MASTERMAKEFILE)

ISCSI_DIR:=iscsitarget-1.4.20.1
ISCSI_TARGET_DIR:=$(BT_BUILD_DIR)/iscsi
 
source: 		
	-rm -rf $(ISCSI_DIR)
	zcat $(ISCSI_SOURCE) | tar -xvf -
#	cat $(ISCSI_PATCH1) | patch -d $(ISCSI_DIR) -p1

build:
	mkdir -p $(ISCSI_TARGET_DIR)/usr/sbin
	mkdir -p $(ISCSI_TARGET_DIR)/lib/modules
	mkdir -p $(ISCSI_TARGET_DIR)/etc/init.d
	mkdir -p $(ISCSI_TARGET_DIR)/etc/modules.d
	(for i in $(KARCHS); do \
	mkdir -p $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/iscsi && \
	$(MAKE) KSRC=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) -C $(ISCSI_DIR) && \
	cp -a $(ISCSI_DIR)/kernel/iscsi_trgt.ko $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/iscsi && \
	$(BT_DEPMOD) -ae -b $(BT_STAGING_DIR) -r -F $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/build/System.map $(BT_KERNEL_RELEASE)-$$i ; \
	done)
	cp -a $(ISCSI_DIR)/usr/ietd $(ISCSI_TARGET_DIR)/usr/sbin
	cp -a $(ISCSI_DIR)/usr/ietadm $(ISCSI_TARGET_DIR)/usr/sbin
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ISCSI_TARGET_DIR)/usr/sbin/*
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
	rm -f $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)/kernel/iscsi/iscsi_trgt.o
