# makefile for modules
include $(MASTERMAKEFILE)

CONFIG_DIR=.
CONFIG_TARGET_DIR:=$(BT_BUILD_DIR)/modules

$(CONFIG_DIR)/.source:
	touch $(CONFIG_DIR)/.source

source: $(CONFIG_DIR)/.source

$(CONFIG_DIR)/.configured: $(CONFIG_DIR)/.source
	touch $(CONFIG_DIR)/.configured

$(CONFIG_DIR)/.build: $(CONFIG_DIR)/.configured
	mkdir -p $(CONFIG_TARGET_DIR)
	mkdir -p $(CONFIG_TARGET_DIR)/etc/init.d
	cp -aL modules $(CONFIG_TARGET_DIR)/etc
	cp -aL modutils $(CONFIG_TARGET_DIR)/etc/init.d
	cp -aL modutils.conf $(CONFIG_TARGET_DIR)/etc
	cp -aL modprobe.conf $(CONFIG_TARGET_DIR)/etc
	cp -a $(CONFIG_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(CONFIG_DIR)/.build

build: $(CONFIG_DIR)/.build

clean:
	rm -rf $(CONFIG_TARGET_DIR)
	rm -f $(CONFIG_DIR)/.build
	rm -f $(CONFIG_DIR)/.configured

srcclean: clean
	rm -f $(CONFIG_DIR)/.source
