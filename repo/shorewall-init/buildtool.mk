######################################
#
# buildtool makefile for Shorewall (init) Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall-init

SHOREWALL-INIT_DIR:=shorewall-init-4.5.0.3

$(SHOREWALL-INIT_DIR)/.source:
	zcat $(SHOREWALL-INIT_SOURCE) | tar -xvf -
	cat $(SHOREWALL_INIT_DIFF) | patch -d $(SHOREWALL-INIT_DIR) -p1
	touch $(SHOREWALL-INIT_DIR)/.source

#errata

$(SHOREWALL-INIT_DIR)/.build: $(SHOREWALL-INIT_DIR)/.source
	cp $(SHOREWALL-INIT_DIR)/init.debian.sh $(SHOREWALL-INIT_DIR)/init.sh
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL-INIT_DIR); env PREFIX=$(TARGET_DIR) ./install.sh)
	
#	mkdir -p $(TARGET_DIR)/etc/default
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SHOREWALL-INIT_DIR)/.build

source: $(SHOREWALL-INIT_DIR)/.source

build:  $(SHOREWALL-INIT_DIR)/.build                                                                                                   
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL-INIT_DIR)/.build

stageclean:
	rm -f  $(BT_STAGING_DIR)/etc/init.d/shorewall
#	rm -f  $(BT_STAGING_DIR)/etc/default/shorewall

srcclean: clean
	rm -rf $(SHOREWALL-INIT_DIR)
