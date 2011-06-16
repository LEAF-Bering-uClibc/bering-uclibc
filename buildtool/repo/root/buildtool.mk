#############################################################
#
# root.lrp
# 
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:28 nitr0man Exp $
#############################################################
include $(MASTERMAKEFILE)
ROOT_TARGET_DIR:=$(BT_BUILD_DIR)/root

source: 

build: 
	mkdir -p $(ROOT_TARGET_DIR)
	mkdir -p $(ROOT_TARGET_DIR)/bin
	mkdir -p $(ROOT_TARGET_DIR)/sbin	
	mkdir -p $(ROOT_TARGET_DIR)/usr/bin		
	mkdir -p $(ROOT_TARGET_DIR)/usr/sbin		
	mkdir -p $(ROOT_TARGET_DIR)/root
	mkdir -p $(ROOT_TARGET_DIR)/var/lib	
	mkdir -p $(ROOT_TARGET_DIR)/var/lib/lrpkg		
	cp -aL edit $(ROOT_TARGET_DIR)/bin
	cp -aL ticker $(ROOT_TARGET_DIR)/usr/sbin	
	cp -aL savelog $(ROOT_TARGET_DIR)/usr/bin	
	cp -aL getservbyname $(ROOT_TARGET_DIR)/usr/sbin	
	cp -aL svi $(ROOT_TARGET_DIR)/usr/sbin	
	cp -aL update-rc.d $(ROOT_TARGET_DIR)/usr/sbin	
	cp -aL profile $(ROOT_TARGET_DIR)/root/.profile	
	cp -aL root.dev.mod $(ROOT_TARGET_DIR)/var/lib/lrpkg				
	cp -aL root.dev.own $(ROOT_TARGET_DIR)/var/lib/lrpkg			
	cp -a $(ROOT_TARGET_DIR)/* $(BT_STAGING_DIR)
        
clean:
  
srcclean:

