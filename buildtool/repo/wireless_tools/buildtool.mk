#############################################################
#
# Wireless Extensions for Linux
#
#############################################################

include $(MASTERMAKEFILE)

WIRELESS_TOOLS_DIR:=wireless_tools.30
WIRELESS_TOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/wireless_tools

$(WIRELESS_TOOLS_DIR)/.source:
	zcat $(WIRELESS_TOOLS_SOURCE) | tar -xvf -
	touch $(WIRELESS_TOOLS_DIR)/.source	

$(WIRELESS_TOOLS_DIR)/.build: $(WIRELESS_TOOLS_DIR)/.source
	mkdir -p $(WIRELESS_TOOLS_TARGET_DIR)
	mkdir -p $(WIRELESS_TOOLS_TARGET_DIR)/sbin
	mkdir -p $(WIRELESS_TOOLS_TARGET_DIR)/etc/network/if-pre-up.d
	make CC=$(TARGET_CC) iwmulticall DEPFLAGS=  -C $(WIRELESS_TOOLS_DIR) 
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(WIRELESS_TOOLS_DIR)/iwmulticall
	cp -aL wireless-pre-up $(WIRELESS_TOOLS_TARGET_DIR)/etc/network/if-pre-up.d/wireless
	cp -a $(WIRELESS_TOOLS_DIR)/iwmulticall $(WIRELESS_TOOLS_TARGET_DIR)/sbin/iwconfig
	cp -a $(WIRELESS_TOOLS_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(WIRELESS_TOOLS_DIR)/.build

source: $(WIRELESS_TOOLS_DIR)/.source

build: $(WIRELESS_TOOLS_DIR)/.build
	
clean:
	make -C $(WIRELESS_TOOLS_DIR) clean
	rm -rf $(WIRELESS_TOOLS_TARGET_DIR)
	rm $(WIRELESS_TOOLS_DIR)/.build
	rm -f $(BT_STAGING_DIR)/sbin/iwconfig
	rm -f $(BT_STAGING_DIR)/etc/network/if-pre-up.d/wireless
	-rmdir  $(BT_STAGING_DIR)/etc/network/if-pre-up.d
	-rmdir  $(BT_STAGING_DIR)/etc/network

srcclean:
	rm -rf $(WIRELESS_TOOLS_DIR)
