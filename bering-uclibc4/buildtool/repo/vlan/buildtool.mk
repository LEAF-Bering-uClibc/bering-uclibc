# makefile for vlan
include $(MASTERMAKEFILE)

VLAN_DIR:=vlan
VLAN_TARGET_DIR:=$(BT_BUILD_DIR)/vlan

$(VLAN_DIR)/.source:
	zcat $(VLAN_SOURCE) | tar -xvf -
	touch $(VLAN_DIR)/.source

source: $(VLAN_DIR)/.source
                        
$(VLAN_DIR)/.configured: $(VLAN_DIR)/.source
	touch $(VLAN_DIR)/.configured
                                                                 
$(VLAN_DIR)/.build: $(VLAN_DIR)/.configured
	mkdir -p $(VLAN_TARGET_DIR)
	mkdir -p $(VLAN_TARGET_DIR)/etc/network/if-pre-up.d	
	mkdir -p $(VLAN_TARGET_DIR)/etc/network/if-post-down.d	
	mkdir -p $(VLAN_TARGET_DIR)/etc/network/if-up.d			
	mkdir -p $(VLAN_TARGET_DIR)/sbin	
	$(MAKE) -C $(VLAN_DIR) CCFLAGS="-g -D_GNU_SOURCE -Wall -Iinclude-2.4" vconfig
#	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(VLAN_DIR)/vconfig	
	cp -aL ip $(VLAN_TARGET_DIR)/etc/network/if-up.d
	cp -aL vlan.pre $(VLAN_TARGET_DIR)/etc/network/if-pre-up.d/vlan
	cp -aL vlan.post $(VLAN_TARGET_DIR)/etc/network/if-post-down.d/vlan	
	cp -a $(VLAN_DIR)/vconfig $(VLAN_TARGET_DIR)/sbin
	cp -a $(VLAN_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(VLAN_DIR)/.build

build: $(VLAN_DIR)/.build
                                                                                         
clean:
	rm -f $(VLAN_DIR)/vconfig.h 
	rm -f $(VLAN_DIR)/vconfig.o 
	rm -f $(VLAN_DIR)/vconfig
	rm -rf $(VLAN_TARGET_DIR)
	rm -rf $(VLAN_DIR)/.build
	rm -rf $(VLAN_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(VLAN_DIR) 
	rm -rf $(VLAN_DIR)/.source
