######################################
#
# buildtool makefile for Shoreline Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall6-lite

SHOREWALL_DIR:=shorewall6-lite-4.5.1.1

$(SHOREWALL_DIR)/.source:
	zcat $(SHOREWALL_SOURCE) | tar -xvf -
	touch $(SHOREWALL_DIR)/.source


$(SHOREWALL_DIR)/.build: $(SHOREWALL_DIR)/.source
#	cp $(SHOREWALL_DIR)/init.debian.sh $(SHOREWALL_DIR)/init.sh
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL_DIR); env PREFIX=$(TARGET_DIR) ./install.sh)

	mkdir -p $(TARGET_DIR)/etc/default
	install -c $(SHOREWALL6_DEFAULT) $(TARGET_DIR)/etc/default/shorewall6-lite
	rm -f $(TARGET_DIR)/etc/init.d/shorewall6-lite
	cp $(SHOREWALL6_INIT) $(TARGET_DIR)/etc/init.d/shorewall6-lite

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

srcclean: clean
	rm -rf $(SHOREWALL_DIR)
