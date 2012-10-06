include $(MASTERMAKEFILE)

BBNAMEIF_DIR=bbnameif
BBNAMEIF_BUILD_DIR=$(BT_BUILD_DIR)/$(BBNAMEIF_DIR)

.source:
	mkdir -p $(BBNAMEIF_DIR)
	touch .source
	
.build: source  
	mkdir -p $(BBNAMEIF_BUILD_DIR)
	mkdir -p $(BBNAMEIF_BUILD_DIR)/etc/init.d
	-mkdir -p $(BT_STAGING_DIR)/etc/init.d
	
	cp -aL nameif $(BBNAMEIF_BUILD_DIR)/etc/init.d/nameif
	cp -aL mactab $(BBNAMEIF_BUILD_DIR)/etc/mactab
	cp -aL mactab.tmp $(BBNAMEIF_BUILD_DIR)/etc/mactab.tmp
	cp -a $(BBNAMEIF_BUILD_DIR)/* $(BT_STAGING_DIR)
	cp -a $(BBNAMEIF_BUILD_DIR)/etc/init.d/* $(BT_STAGING_DIR)/etc/init.d/
	touch .build

source: .source

build: .build

clean:  
	-rm .build
	-rm -r $(BBNAMEIF_BUILD_DIR)

srcclean:
	rm -rf $(BBNAMEIF_DIR)	
