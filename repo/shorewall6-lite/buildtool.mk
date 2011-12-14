######################################
#
# buildtool makefile for Shoreline Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall6-lite

SHOREWALL_DIR:=shorewall6-lite-4.4.26.1

$(SHOREWALL_DIR)/.source:
	zcat $(SHOREWALL_SOURCE) | tar -xvf -
#	cat $(SHOREWALL_DATE_DIFF)      | patch -d $(SHOREWALL_DIR) -p1
	touch $(SHOREWALL_DIR)/.source


$(SHOREWALL_DIR)/.build: $(SHOREWALL_DIR)/.source
#	cp $(SHOREWALL_DIR)/init.debian.sh $(SHOREWALL_DIR)/init.sh
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL_DIR); env PREFIX=$(TARGET_DIR) ./install.sh)
	
	mkdir -p $(TARGET_DIR)/etc/default
	install -c $(SHOREWALL6_DEFAULT) $(TARGET_DIR)/etc/default/shorewall6-lite
	install -c $(SHOREWALL6_INIT) $(TARGET_DIR)/etc/init.d/shorewall6-lite

	rm -rf $(TARGET_DIR)/etc/shorewall6/Makefile
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SHOREWALL_DIR)/.build

source: $(SHOREWALL_DIR)/.source

build:  $(SHOREWALL_DIR)/.build                                                                                                   
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL_DIR)/.build

stageclean:
	rm -f  $(BT_STAGING_DIR)/etc/init.d/shorewall6-lite
	rm -f  $(BT_STAGING_DIR)/etc/default/shorewall6-lite
#	rm -f  $(BT_STAGING_DIR)/sbin/shorewall
#	rm -rf $(BT_STAGING_DIR)/etc/shorewall
#	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall
#	rm -rf $(BT_STAGING_DIR)/var/lib/shorewall
#	rm -rf $(BT_STAGING_DIR)/var/state/shorewall

srcclean: clean
	rm -rf $(SHOREWALL_DIR)
