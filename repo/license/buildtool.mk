#
# makefile for license.lrp
# collects the licenses we have to provide
#
include $(MASTERMAKEFILE)

LICENSE_DIR=.
LICENSE_TARGET_DIR:=$(BT_BUILD_DIR)/license

$(LICENSE_DIR)/.source:
	touch $(LICENSE_DIR)/.source

source: $(LICENSE_DIR)/.source
                        
$(LICENSE_DIR)/.build: $(LICENSE_DIR)/.source
	mkdir -p $(LICENSE_TARGET_DIR)/licenses
	cp -aL [A-Z]* $(LICENSE_TARGET_DIR)/licenses/
	cp -a $(LICENSE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LICENSE_DIR)/.build

build: $(LICENSE_DIR)/.build
                                                                                         
clean:
	rm -rf $(LICENSE_TARGET_DIR)
	rm -f $(LICENSE_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -f $(LICENSE_DIR)/.source
