#############################################################
#
# Wireless Extensions for Linux
#
#############################################################


WIRELESS_TOOLS_DIR:=wireless_tools.30
WIRELESS_TOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/wireless_tools

.source:
	zcat $(WIRELESS_TOOLS_SOURCE) | tar -xvf -
	touch .source

.build: .source
	mkdir -p $(WIRELESS_TOOLS_TARGET_DIR)
	mkdir -p $(WIRELESS_TOOLS_TARGET_DIR)/sbin
	mkdir -p $(WIRELESS_TOOLS_TARGET_DIR)/etc/network/if-pre-up.d
	make CC=$(TARGET_CC)  AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) \
	    iwmulticall DEPFLAGS=  -C $(WIRELESS_TOOLS_DIR)
	cp -aL wireless-pre-up $(WIRELESS_TOOLS_TARGET_DIR)/etc/network/if-pre-up.d/wireless
	cp -a $(WIRELESS_TOOLS_DIR)/iwmulticall $(WIRELESS_TOOLS_TARGET_DIR)/sbin/iwconfig
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(WIRELESS_TOOLS_TARGET_DIR)/sbin/*
	cp -a $(WIRELESS_TOOLS_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

source: .source

build: .build

clean:
	make -C $(WIRELESS_TOOLS_DIR) clean
	rm -rf $(WIRELESS_TOOLS_TARGET_DIR)
	rm -f .build
	rm -f $(BT_STAGING_DIR)/sbin/iwconfig
	rm -f $(BT_STAGING_DIR)/etc/network/if-pre-up.d/wireless
	-rmdir  $(BT_STAGING_DIR)/etc/network/if-pre-up.d
	-rmdir  $(BT_STAGING_DIR)/etc/network

srcclean: clean
	rm -rf $(WIRELESS_TOOLS_DIR)
	rm -f .source
