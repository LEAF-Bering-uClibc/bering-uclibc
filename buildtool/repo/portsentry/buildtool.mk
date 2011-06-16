# makefile for portsentry
include $(MASTERMAKEFILE)

PORTSENTRY_DIR:=portsentry_beta
PORTSENTRY_TARGET_DIR:=$(BT_BUILD_DIR)/portsentry

$(PORTSENTRY_DIR)/.source:
	zcat $(PORTSENTRY_SOURCE) | tar -xvf -
	zcat $(PORTSENTRY_PATCH) | patch -d $(PORTSENTRY_DIR) -p1
	touch $(PORTSENTRY_DIR)/.source

source: $(PORTSENTRY_DIR)/.source

$(PORTSENTRY_DIR)/.build: $(PORTSENTRY_DIR)/.source
	mkdir -p $(PORTSENTRY_TARGET_DIR)
	mkdir -p $(PORTSENTRY_TARGET_DIR)/usr/sbin
	mkdir -p $(PORTSENTRY_TARGET_DIR)/etc/portsentry
	mkdir -p $(PORTSENTRY_TARGET_DIR)/etc/default
	mkdir -p $(PORTSENTRY_TARGET_DIR)/etc/init.d
	make CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS) -Wall -g" -f Makefile debian-linux -C $(PORTSENTRY_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(PORTSENTRY_DIR)/portsentry
	cp -a $(PORTSENTRY_DIR)/portsentry $(PORTSENTRY_TARGET_DIR)/usr/sbin
	cp -aL portsentry.conf $(PORTSENTRY_TARGET_DIR)/etc/portsentry
	cp -aL portsentry.ignore $(PORTSENTRY_TARGET_DIR)/etc/portsentry
	cp -aL portsentry.default $(PORTSENTRY_TARGET_DIR)/etc/default/portsentry
	cp -aL portsentry.init $(PORTSENTRY_TARGET_DIR)/etc/init.d/portsentry
	cp -a $(PORTSENTRY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PORTSENTRY_DIR)/.build

build: $(PORTSENTRY_DIR)/.build
                                                                                         
clean:
	make -C $(PORTSENTRY_DIR) -f Makefile clean
	rm -rf $(PORTSENTRY_TARGET_DIR)
	rm -f $(PORTSENTRY_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(PORTSENTRY_DIR) 
	rm -f $(PORTSENTRY_DIR)/.source
