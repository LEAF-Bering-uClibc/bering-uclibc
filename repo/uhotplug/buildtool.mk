# makefile for uhotplug
include $(MASTERMAKEFILE)

UHOTPLUG_DIR=.
UHOTPLUG_TARGET_DIR:=$(BT_BUILD_DIR)/uhotplug

$(UHOTPLUG_DIR)/.source:
	touch $(UHOTPLUG_DIR)/.source

source: $(UHOTPLUG_DIR)/.source

$(UHOTPLUG_DIR)/.configured: $(UHOTPLUG_DIR)/.source
	touch $(UHOTPLUG_DIR)/.configured

$(UHOTPLUG_DIR)/.build: $(UHOTPLUG_DIR)/.configured
	mkdir -p $(UHOTPLUG_TARGET_DIR)
	mkdir -p $(UHOTPLUG_TARGET_DIR)/sbin
	mkdir -p $(UHOTPLUG_TARGET_DIR)/etc/hotplug
	mkdir -p $(UHOTPLUG_TARGET_DIR)/etc/hotplug.d/default
	mkdir -p $(UHOTPLUG_TARGET_DIR)/etc/default
	cp -aL net.agent $(UHOTPLUG_TARGET_DIR)/etc/hotplug
	cp -aL firmware.agent $(UHOTPLUG_TARGET_DIR)/etc/hotplug
	cp -aL hotplug.functions $(UHOTPLUG_TARGET_DIR)/etc/hotplug
	cp -aL hotplug.default $(UHOTPLUG_TARGET_DIR)/etc/default/hotplug
	cp -aL default.hotplug $(UHOTPLUG_TARGET_DIR)/etc/hotplug.d/default
	cp -aL hotplug $(UHOTPLUG_TARGET_DIR)/sbin
	cp -a $(UHOTPLUG_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(UHOTPLUG_DIR)/.build

build: $(UHOTPLUG_DIR)/.build

clean:
	rm -rf $(UHOTPLUG_TARGET_DIR)
	rm $(UHOTPLUG_DIR)/.build
	rm $(UHOTPLUG_DIR)/.configured

srcclean: clean
	rm -rf $(UHOTPLUG_DIR)
	rm $(UHOTPLUG_DIR)/.source
