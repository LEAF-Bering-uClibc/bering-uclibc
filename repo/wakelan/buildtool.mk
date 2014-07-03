#############################################################
#
# wakelan
#
#############################################################

WAKELAN_DIR:=.
WAKELAN_TARGET_DIR:=$(BT_BUILD_DIR)/wakelan

$(WAKELAN_DIR)/.source:
	touch $(WAKELAN_DIR)/.source

$(WAKELAN_DIR)/.build:
	mkdir -p $(WAKELAN_TARGET_DIR)/etc
	mkdir -p $(WAKELAN_TARGET_DIR)/usr/bin
	cp -a $(WAKELAN_DIR)/wakeonlan $(WAKELAN_TARGET_DIR)/usr/bin/wakeonlan
	cp -aL wakeonlan.cfg  $(WAKELAN_TARGET_DIR)/etc/
	cp -aL wakeonlan.arp  $(WAKELAN_TARGET_DIR)/etc/
	cp -a $(WAKELAN_TARGET_DIR)/* $(BT_STAGING_DIR)/
	echo $(BT_STAGING_DIR)
	touch $(WAKELAN_DIR)/.build

source: $(WAKELAN_DIR)/.source

build: $(WAKELAN_DIR)/.build

clean:
	rm -rf $(WAKELAN_TARGET_DIR)
	rm -f $(WAKELAN_DIR)/.build
	rm -f $(WAKELAN_DIR)/.configured

srcclean: clean
	rm -f $(WAKELAN_DIR)/*
	rm -f $(WAKELAN_DIR)/.source
