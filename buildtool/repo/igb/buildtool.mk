# makefile for accel-pptp
include $(MASTERMAKEFILE)

DIR:=igb-3.0.22
TARGET_DIR:=$(BT_BUILD_DIR)/igb
MODULE_PATH=kernel/drivers/net/igb

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.build: 
	(cd $(DIR)/src && for i in $(KARCHS); do export LOCALVERSION="-$$i" ; \
	mkdir -p $(TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/$(MODULE_PATH) ; \
	$(MAKE) $(EXTRA_VARS) KSRC=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) clean && \
	$(MAKE) $(EXTRA_VARS) KSRC=$(BT_LINUX_DIR)-$$i CC=$(TARGET_CC) && \
	cp -a igb.ko $(TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/$(MODULE_PATH) ||\
	exit 1 ; $(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/$(MODULE_PATH)/igb.ko; \
	done)
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	rm -rf $(TARGET_DIR)
#	$(MAKE) -C $(DIR) clean
	rm -f $(DIR)/.build

srcclean: clean
	rm -rf $(DIR)
	rm -f $(DIR)/.source
