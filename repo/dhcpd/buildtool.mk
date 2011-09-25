# makefile for dhcpd
include $(MASTERMAKEFILE)

SOURCE_TARBALL=dhcp-4.2.2.tar.gz
SOURCE_DIR:=$(shell basename `tar tzf $(SOURCE_TARBALL) | head -1`)
TARGET_DIR:=$(BT_BUILD_DIR)/dhcpd

.source:
	zcat $(SOURCE_TARBALL) | tar -xvf -
	#zcat $(DHCPD_PATCH1) | patch -d $(SOURCE_DIR) -p1
	touch $(SOURCE_DIR)/.source


#unpatch:
#	if [ -f .patched ]; then ( cd $(SOURCE_DIR) && /bin/sh debian/scripts/unpatch-source ); fi
#	rm -f .patched

#.patched: .source
#	( cd $(SOURCE_DIR) && /bin/sh debian/scripts/patch-source );
#	touch .patched
 
source: .source
                        
.configured: .source
	(cd $(SOURCE_DIR) ; LD=$(TARGET_LD) ./configure )
	touch .configured
                                                                 
.build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/sbin
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/etc/default
	make -C $(SOURCE_DIR) CC=$(TARGET_CC) PREDEFINES='-D_PATH_DHCPD_DB=\"/var/lib/dhcp/dhcpd.leases\" \
	-D_PATH_DHCLIENT_DB=\"/var/lib/dhcp/dhclient.leases\"' VARDB=/var/lib/dhcp
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SOURCE_DIR)/server/dhcpd
	cp -a $(SOURCE_DIR)/server/dhcpd $(TARGET_DIR)/usr/sbin
	cp -aL dhcpd.conf $(TARGET_DIR)/etc	
	cp -aL dhcp $(TARGET_DIR)/etc/default	
	cp -aL dhcp.init $(TARGET_DIR)/etc/init.d/dhcp			
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build
                                                                                         
clean: 
	make -C $(SOURCE_DIR) distclean
	rm -rf $(TARGET_DIR)
	rm .build
	rm .configured
                                                                                                                 
srcclean: clean
	rm -rf $(SOURCE_DIR) 
	rm .source
