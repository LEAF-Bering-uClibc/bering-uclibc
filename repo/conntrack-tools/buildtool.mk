#########################################
# makefile for conntrack-tools
#########################################

CONNTRACK-TOOLS_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(CONNTRACK-TOOLS_SOURCE) 2>/dev/null )
CONNTRACK-TOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/conntrack-tools

$(CONNTRACK-TOOLS_DIR)/.source:
	bzcat $(CONNTRACK-TOOLS_SOURCE) |  tar -xvf -
	touch $(CONNTRACK-TOOLS_DIR)/.source

$(CONNTRACK-TOOLS_DIR)/.configured: $(CONNTRACK-TOOLS_DIR)/.source
	(cd $(CONNTRACK-TOOLS_DIR) ; ./configure --prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) )
	touch $(CONNTRACK-TOOLS_DIR)/.configured

source: $(CONNTRACK-TOOLS_DIR)/.source

$(CONNTRACK-TOOLS_DIR)/.build: $(CONNTRACK-TOOLS_DIR)/.configured
	mkdir -p $(CONNTRACK-TOOLS_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/conntrackd
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	$(MAKE) -C $(CONNTRACK-TOOLS_DIR)
	$(MAKE) DESTDIR=$(CONNTRACK-TOOLS_TARGET_DIR) -C $(CONNTRACK-TOOLS_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(CONNTRACK-TOOLS_TARGET_DIR)/usr/sbin/conntrack*
	cp -aL conntrackd.init $(BT_STAGING_DIR)/etc/init.d/conntrackd
	cp -a $(CONNTRACK-TOOLS_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin
	cp -a $(CONNTRACK-TOOLS_DIR)/doc/stats/conntrackd.conf $(BT_STAGING_DIR)/etc/conntrackd/conntrackd.conf
	touch $(CONNTRACK-TOOLS_DIR)/.build

build: $(CONNTRACK-TOOLS_DIR)/.build

clean:
	-rm $(CONNTRACK-TOOLS_DIR)/.build
	rm -rf $(CONNTRACK-TOOLS_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/sbin/conntrack*
	rm -f $(BT_STAGING_DIR)/etc/init.d/conntrackd $(BT_STAGING_DIR)/etc/conntrackd/conntrackd.conf
	$(MAKE) -C $(CONNTRACK-TOOLS_DIR) clean

srcclean:
	rm -rf $(CONNTRACK-TOOLS_DIR)

