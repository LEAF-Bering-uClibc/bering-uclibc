#############################################################
#
# dhcp-helper
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:03:04 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
DHCP-HELPER_DIR:=dhcp-helper-0.7
DHCP-HELPER_TARGET_DIR:=$(BT_BUILD_DIR)/dhcp-helper


$(DHCP-HELPER_DIR)/.source: 
	zcat $(DHCP-HELPER_SOURCE) |  tar -xvf - 
	touch $(DHCP-HELPER_DIR)/.source

$(DHCP-HELPER_DIR)/.build:
	mkdir -p $(DHCP-HELPER_TARGET_DIR)
	mkdir -p $(DHCP-HELPER_TARGET_DIR)/usr/sbin
	mkdir -p $(DHCP-HELPER_TARGET_DIR)/etc/default
	mkdir -p $(DHCP-HELPER_TARGET_DIR)/etc/init.d
	$(MAKE) CC=$(TARGET_CC) -C $(DHCP-HELPER_DIR) PREFIX=/usr CFLAGS="$(BT_COPT_FLAGS)"
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DHCP-HELPER_DIR)/dhcp-helper
	cp -a $(DHCP-HELPER_DIR)/dhcp-helper $(DHCP-HELPER_TARGET_DIR)/usr/sbin
	cp -aL dhcp-helper.init $(DHCP-HELPER_TARGET_DIR)/etc/init.d/dhcp-helper
	cp -aL dhcp-helper.default $(DHCP-HELPER_TARGET_DIR)/etc/default/dhcp-helper
	cp -a $(DHCP-HELPER_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DHCP-HELPER_DIR)/.build

source: $(DHCP-HELPER_DIR)/.source 

build: $(DHCP-HELPER_DIR)/.build

clean:
	-rm $(DHCP-HELPER_DIR)/.build
	$(MAKE) -C $(DHCP-HELPER_DIR) clean
  
srcclean:
	rm -rf $(DHCP-HELPER_DIR)
