include $(MASTERMAKEFILE)
CONNTRACK-TOOLS_DIR:=conntrack-tools-1.0.0
CONNTRACK-TOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/conntrack-tools
export CC=$(TARGET_CC)
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment 

$(CONNTRACK-TOOLS_DIR)/.source: 		
	bzcat $(CONNTRACK-TOOLS_SOURCE) |  tar -xvf - 	
	touch $(CONNTRACK-TOOLS_DIR)/.source

$(CONNTRACK-TOOLS_DIR)/.configured: $(CONNTRACK-TOOLS_DIR)/.source
	(cd $(CONNTRACK-TOOLS_DIR) ; ./configure --prefix=/usr )
	touch $(CONNTRACK-TOOLS_DIR)/.configured

source: $(CONNTRACK-TOOLS_DIR)/.source

$(CONNTRACK-TOOLS_DIR)/.build: $(CONNTRACK-TOOLS_DIR)/.configured
	mkdir -p $(CONNTRACK-TOOLS_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/conntrackd
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	$(MAKE) -C $(CONNTRACK-TOOLS_DIR) 	
	$(MAKE) DESTDIR=$(CONNTRACK-TOOLS_TARGET_DIR) -C $(CONNTRACK-TOOLS_DIR) install
	cp -aL conntrackd.init $(BT_STAGING_DIR)/etc/init.d/conntrackd
	cp -a $(CONNTRACK-TOOLS_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin
	cp -a $(CONNTRACK-TOOLS_DIR)/doc/stats/conntrackd.conf $(BT_STAGING_DIR)/etc/conntrackd/conntrackd.conf
	touch $(CONNTRACK-TOOLS_DIR)/.build

build: $(CONNTRACK-TOOLS_DIR)/.build

clean:
	-rm $(CONNTRACK-TOOLS_DIR)/.build
	rm -rf $(CONNTRACK-TOOLS_TARGET_DIR)
#	rm -f $(BT_STAGING_DIR)/usr/lib/libnfnet.* 
#	rm -rf $(BT_STAGING_DIR)/usr/include/libnfnetlink
	$(MAKE) -C $(CONNTRACK-TOOLS_DIR) clean
	
srcclean:
	rm -rf $(CONNTRACK-TOOLS_DIR)

