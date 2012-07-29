######################################
#
# buildtool makefile for Shorewall Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall

SHOREWALL_DIR:=shorewall-4.5.5.2

$(SHOREWALL_DIR)/.source:
	zcat $(SHOREWALL_SOURCE) | tar -xvf -
#	cat $(SHOREWALL_DATE_DIFF)	| patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_LRP_DIFF)	| patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_INTERFACES_PATCH) | patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_MASQ_PATCH) | patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_RULES_PATCH) | patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_ZONES_PATCH) | patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_POLICY_PATCH) | patch -d $(SHOREWALL_DIR) -p1
	cat $(SHOREWALL_INSTALL_PATCH) | patch -d $(SHOREWALL_DIR) -p1
#	cat $(SHOREWALL_CHAINS_PATCH) | patch -d $(SHOREWALL_DIR) -p1
	touch $(SHOREWALL_DIR)/.source

#errata
#	cp compiler $(SHOREWALL_DIR)	

$(SHOREWALL_DIR)/.configured: $(SHOREWALL_DIR)/.source
	( cd $(SHOREWALL_DIR); ./configure \
	--host=linux \
	--build=linux \
	--prefix=/usr \
	--sharedir=/usr/share \
	--libexecdir=/usr/share \
	--perllibdir=/usr/share/shorewall \
	--confdir=/etc \
	--sbindir=/sbin \
	--initdir=/etc/init.d \
	--initfile=shorewall \
	--initsource=init.sh \
	--annotated= \
	--vardir=/var/lib \
	--sysconfdir=/etc/shorewall )
	touch $(SHOREWALL_DIR)/.configured


$(SHOREWALL_DIR)/.build: $(SHOREWALL_DIR)/.configured
	cp init.sh $(SHOREWALL_DIR)/init.sh
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL_DIR); DESTDIR=$(TARGET_DIR) DIGEST=SHA1 ./install.sh)	
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

build: $(SHOREWALL_DIR)/.build

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL_DIR)/.build
	rm -f  $(SHOREWALL_DIR)/.configured

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
