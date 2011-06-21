#####################################################
# 
# webconf - based on weblet buildtool.mk
# 
#####################################################
include $(MASTERMAKEFILE)

#####################################################
# Build webconf

WEBCONF_DIR:=$(shell basename `tar tzf $(SOURCE_TARBALL) | head -1`)
WEBCONF_TARGET_DIR:=$(BT_BUILD_DIR)/webconf

source: .source 

.source:
	(zcat $(SOURCE_TARBALL) | tar -xvf - )
	echo $(WEBCONF_DIR) > .source
                        
.configured: .source
	touch .configured
                                                                 
.build: .configured
	mkdir -p $(WEBCONF_TARGET_DIR)
	mkdir -p $(WEBCONF_TARGET_DIR)/etc/init.d
	mkdir -p $(WEBCONF_TARGET_DIR)/etc/webconf
	mkdir -p $(WEBCONF_TARGET_DIR)/var/webconf
	cp -a $(WEBCONF_DIR)/etc/init.d/webconf $(WEBCONF_TARGET_DIR)/etc/init.d
	cp -a $(WEBCONF_DIR)/etc/webconf/webconf.conf $(WEBCONF_TARGET_DIR)/etc/webconf
	cp -a $(WEBCONF_DIR)/etc/webconf/webconf.webconf $(WEBCONF_TARGET_DIR)/etc/webconf		
	cp -a $(WEBCONF_DIR)/etc/webconf/interfaces.webconf $(WEBCONF_TARGET_DIR)/etc/webconf		
	cp -a $(WEBCONF_DIR)/etc/webconf/tools.webconf $(WEBCONF_TARGET_DIR)/etc/webconf		
	cp -a $(WEBCONF_DIR)/var/webconf/* $(WEBCONF_TARGET_DIR)/var/webconf
	cp -a $(WEBCONF_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	rm -rf $(WEBCONF_TARGET_DIR)
	rm -rf .build
	rm -rf .configured

srcclean: 
	rm -rf `cat .source`
	rm -f .source

