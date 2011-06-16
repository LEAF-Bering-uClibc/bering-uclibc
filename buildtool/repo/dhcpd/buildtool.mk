# makefile for dhcpd
include $(MASTERMAKEFILE)

DHCPD_DIR:=dhcp-2.0pl5
DHCPD_TARGET_DIR:=$(BT_BUILD_DIR)/dhcpd

$(DHCPD_DIR)/.source:
	zcat $(DHCPD_SOURCE) | tar -xvf -
	zcat $(DHCPD_PATCH1) | patch -d $(DHCPD_DIR) -p1
	touch $(DHCPD_DIR)/.source


unpatch:
	if [ -f $(DHCPD_DIR)/.patched ]; then ( cd $(DHCPD_DIR) && /bin/sh debian/scripts/unpatch-source ); fi
	rm -f $(DHCPD_DIR)/.patched

$(DHCPD_DIR)/.patched: $(DHCPD_DIR)/.source
	( cd $(DHCPD_DIR) && /bin/sh debian/scripts/patch-source );
	touch $(DHCPD_DIR)/.patched
 
source: $(DHCPD_DIR)/.source
                        
$(DHCPD_DIR)/.configured: $(DHCPD_DIR)/.patched
	(cd $(DHCPD_DIR) ; LD=$(TARGET_LD) ./configure )
	touch $(DHCPD_DIR)/.configured
                                                                 
$(DHCPD_DIR)/.build: $(DHCPD_DIR)/.configured
	mkdir -p $(DHCPD_TARGET_DIR)
	mkdir -p $(DHCPD_TARGET_DIR)/usr/sbin
	mkdir -p $(DHCPD_TARGET_DIR)/etc/init.d
	mkdir -p $(DHCPD_TARGET_DIR)/etc/default
	make -C $(DHCPD_DIR) CC=$(TARGET_CC) PREDEFINES='-D_PATH_DHCPD_DB=\"/var/lib/dhcp/dhcpd.leases\" \
	-D_PATH_DHCLIENT_DB=\"/var/lib/dhcp/dhclient.leases\"' VARDB=/var/lib/dhcp
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DHCPD_DIR)/server/dhcpd
	cp -a $(DHCPD_DIR)/server/dhcpd $(DHCPD_TARGET_DIR)/usr/sbin
	cp -aL dhcpd.conf $(DHCPD_TARGET_DIR)/etc	
	cp -aL dhcp $(DHCPD_TARGET_DIR)/etc/default	
	cp -aL dhcp.init $(DHCPD_TARGET_DIR)/etc/init.d/dhcp			
	cp -a $(DHCPD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DHCPD_DIR)/.build

build: $(DHCPD_DIR)/.build
                                                                                         
clean: unpatch
	make -C $(DHCPD_DIR) distclean
	rm -rf $(DHCPD_TARGET_DIR)
	rm $(DHCPD_DIR)/.build
	rm $(DHCPD_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(DHCPD_DIR) 
	rm $(DHCPD_DIR)/.source
