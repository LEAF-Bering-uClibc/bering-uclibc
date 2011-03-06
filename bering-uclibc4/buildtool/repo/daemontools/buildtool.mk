# makefile for daemontools
include $(MASTERMAKEFILE)

DAEMONTOOLS_DIR:=admin/daemontools-0.76
DAEMONTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/daemontools

$(DAEMONTOOLS_DIR)/.source:
	zcat $(DAEMONTOOLS_SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p2 -d $(DAEMONTOOLS_DIR)
	touch $(DAEMONTOOLS_DIR)/.source

source: $(DAEMONTOOLS_DIR)/.source
                        
$(DAEMONTOOLS_DIR)/.configured: $(DAEMONTOOLS_DIR)/.source
# 	(cd $(DAEMONTOOLS_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure )
	touch $(DAEMONTOOLS_DIR)/.configured
                                                                 
$(DAEMONTOOLS_DIR)/.build: $(DAEMONTOOLS_DIR)/.configured
	cd $(DAEMONTOOLS_DIR)
	mkdir -p $(DAEMONTOOLS_TARGET_DIR)/usr/bin
	mkdir -p $(DAEMONTOOLS_TARGET_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/etc/init.d	
	(cd $(DAEMONTOOLS_DIR); package/compile );
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/envdir
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/envuidgid
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/fghack
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/multilog
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/pgrphack
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/readproctitle
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/setlock
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/setuidgid
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/softlimit
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/supervise
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/svc
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/svok
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/svscan
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/svscanboot
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/svstat
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/tai64n
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DAEMONTOOLS_DIR)/command/tai64nlocal	
	cp -a $(DAEMONTOOLS_DIR)/command/* $(DAEMONTOOLS_TARGET_DIR)/usr/bin
	chmod 755 $(DAEMONTOOLS_TARGET_DIR)/usr/bin/*
	cp -aL svscan $(DAEMONTOOLS_TARGET_DIR)/etc/init.d/
	cp -a $(DAEMONTOOLS_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DAEMONTOOLS_DIR)/.build

build: $(DAEMONTOOLS_DIR)/.build
                                                                                         
clean:
	rm -rf $(DAEMONTOOLS_TARGET_DIR)
	-rm $(DAEMONTOOLS_DIR)/.build
	-rm $(DAEMONTOOLS_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(DAEMONTOOLS_DIR) 
	-rm $(DAEMONTOOLS_DIR)/.source
