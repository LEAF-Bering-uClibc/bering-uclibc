######################################
#
# buildtool makefile for Shorewall Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall

SHOREWALL_DIR:=shorewall-4.5.1.1

$(SHOREWALL_DIR)/.source:
	zcat $(SHOREWALL_SOURCE) | tar -xvf -
#	cat $(SHOREWALL_DATE_DIFF)	| patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_LRP_DIFF)	| patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_CONFIG_DIFF)	| patch -d $(SHOREWALL_DIR) -p1
	touch $(SHOREWALL_DIR)/.source

#errata
#	cp compiler $(SHOREWALL_DIR)	

$(SHOREWALL_DIR)/.build: $(SHOREWALL_DIR)/.source
	cp init.sh $(SHOREWALL_DIR)/init.sh
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL_DIR); env PREFIX=$(TARGET_DIR) HOST=linux ./install.sh)
	
#	chmod 755 $(TARGET_DIR)/usr/share/shorewall/firewall
	mkdir -p $(TARGET_DIR)/etc/default
	install -c $(SHOREWALL_DEFAULT) $(TARGET_DIR)/etc/default/shorewall

#	rm -rf $(TARGET_DIR)/usr/share/shorewall/configfiles
	rm -rf $(TARGET_DIR)/usr/share/shorewall/macro.template
	rm -rf $(TARGET_DIR)/etc/shorewall/Makefile
	rm -rf $(TARGET_DIR)/etc/shorewall/Documentation
	rm -rf $(TARGET_DIR)/usr/share/shorewall/xmodules
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
	rm -rf $(BT_STAGING_DIR)/etc/shorewall
	rm -rf $(BT_STAGING_DIR)/var/lib/shorewall
	rm -rf $(BT_STAGING_DIR)/var/state/shorewall

	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/action.*
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/actions.std
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/compiler.pl
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/configpath
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/getparams
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/helpers
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/lib.cli-std
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/lib.core
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/macro.*
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/modules*
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/prog*
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/Shorewall
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/version
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall/configfiles

srcclean: clean
	rm -rf $(SHOREWALL_DIR)
