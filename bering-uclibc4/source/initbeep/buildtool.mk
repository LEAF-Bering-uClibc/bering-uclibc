# makefile 
include $(MASTERMAKEFILE)

PKG_DIR=.
PKG_TARGET_DIR:=$(BT_BUILD_DIR)/initbeep

source:
                        
build:
	mkdir -p $(PKG_TARGET_DIR)
	mkdir -p $(PKG_TARGET_DIR)/etc/init.d
	cp -a initbeep $(PKG_TARGET_DIR)/etc/init.d
	cp -a $(PKG_TARGET_DIR)/* $(BT_STAGING_DIR)

                                                                                         
clean:
	rm -rf $(PKG_TARGET_DIR)
                                                                                                                 
srcclean: clean
	rm -rf $(PKG_DIR) 
