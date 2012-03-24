######################################
#
# buildtool makefile for Shorewall Firewall (IPv6)
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall6

SHOREWALL_DIR:=shorewall6-4.5.1.1

$(SHOREWALL_DIR)/.source:
	zcat $(SHOREWALL_SOURCE) | tar -xvf -
	cat $(SHOREWALL_LRP_DIFF)	| patch -d $(SHOREWALL_DIR) -p1
	touch $(SHOREWALL_DIR)/.source

#errata

$(SHOREWALL_DIR)/.build: $(SHOREWALL_DIR)/.source
	cp init.sh $(SHOREWALL_DIR)/init.sh
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL_DIR); env PREFIX=$(TARGET_DIR) ./install.sh)
	
	mkdir -p $(TARGET_DIR)/etc/default
	install -c $(SHOREWALL_DEFAULT) $(TARGET_DIR)/etc/default/shorewall6

#	rm -rf $(TARGET_DIR)/usr/share/shorewall6/configfiles
	rm -rf $(TARGET_DIR)/etc/logrotate.d
	rm -rf $(TARGET_DIR)/usr/share/man
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SHOREWALL_DIR)/.build

source: $(SHOREWALL_DIR)/.source

build:  $(SHOREWALL_DIR)/.build                                                                                                   
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL_DIR)/.build

stageclean:
	rm -f  $(BT_STAGING_DIR)/etc/init.d/shorewall
	rm -f  $(BT_STAGING_DIR)/etc/default/shorewall
	rm -f  $(BT_STAGING_DIR)/sbin/shorewall
	rm -rf $(BT_STAGING_DIR)/etc/shorewall6
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall6
	rm -rf $(BT_STAGING_DIR)/var/lib/shorewall6
	rm -rf $(BT_STAGING_DIR)/var/state/shorewall6
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall6/configfiles

srcclean: clean
	rm -rf $(SHOREWALL_DIR)
