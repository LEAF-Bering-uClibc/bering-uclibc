######################################
#
# buildtool makefile for Shorewall (core) Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall-core

SHOREWALL-CORE_DIR:=shorewall-core-4.5.0.3

$(SHOREWALL-CORE_DIR)/.source:
	zcat $(SHOREWALL-CORE_SOURCE) | tar -xvf -
	touch $(SHOREWALL-CORE_DIR)/.source

#errata

$(SHOREWALL-CORE_DIR)/.build: $(SHOREWALL-CORE_DIR)/.source
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL-CORE_DIR); env PREFIX=$(TARGET_DIR) ./install.sh)
	
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SHOREWALL-CORE_DIR)/.build

source: $(SHOREWALL-CORE_DIR)/.source

build:  $(SHOREWALL-CORE_DIR)/.build                                                                                                   
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL-CORE_DIR)/.build

stageclean:
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall

srcclean: clean
	rm -rf $(SHOREWALL-CORE_DIR)
