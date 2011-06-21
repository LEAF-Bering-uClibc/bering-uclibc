# makefile for wondershaper
include $(MASTERMAKEFILE)

WSHAPER_DIR=.
WSHAPER_TARGET_DIR:=$(BT_BUILD_DIR)/wshaper

$(WSHAPER_DIR)/.source:
	touch $(WSHAPER_DIR)/.source

source: $(WSHAPER_DIR)/.source
                        
$(WSHAPER_DIR)/.configured: $(WSHAPER_DIR)/.source
	touch $(WSHAPER_DIR)/.configured
                                                                 
$(WSHAPER_DIR)/.build: $(WSHAPER_DIR)/.configured
	mkdir -p $(WSHAPER_TARGET_DIR)
	mkdir -p $(WSHAPER_TARGET_DIR)/sbin	
	cp -aL wshaper.cbq $(WSHAPER_TARGET_DIR)/sbin
	cp -aL wshaper.htb $(WSHAPER_TARGET_DIR)/sbin
	cp -a $(WSHAPER_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(WSHAPER_DIR)/.build

build: $(WSHAPER_DIR)/.build
                                                                                         
clean:
	rm -rf $(WSHAPER_TARGET_DIR)
	-rm $(WSHAPER_DIR)/.build
	-rm $(WSHAPER_DIR)/.configured

srcclean: clean
	-rm -rf $(WSHAPER_DIR) 
