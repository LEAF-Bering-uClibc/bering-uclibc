#############################################################
#
# libtool
#
#############################################################

include $(MASTERMAKEFILE)
LIBTOOL_DIR:=libtool-2.4
export CC=$(TARGET_CC)
CFLAGS=-Os -s -I$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/include/include
export CFLAGS
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment 

$(LIBTOOL_DIR)/.source: 		
	zcat $(LIBTOOL_SOURCE) |  tar -xvf - 	
	touch $(LIBTOOL_DIR)/.source

$(LIBTOOL_DIR)/.configured: $(LIBTOOL_DIR)/.source
	(cd $(LIBTOOL_DIR); rm -rf config.cache; \
	CC=$(TARGET_CC)  ./configure \
		--prefix=$(BT_STAGING_DIR) \
		--target=$(BT_TARGET_NAME) \
		--host=$(BT_TARGET_NAME) \
		--build=$(BT_HOST_NAME) );
	touch $(LIBTOOL_DIR)/.configured

source: $(LIBTOOL_DIR)/.source

$(LIBTOOL_DIR)/.build: $(LIBTOOL_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(LIBTOOL_DIR) 
	$(MAKE) CC=$(TARGET_CC) -C $(LIBTOOL_DIR) install
	touch $(LIBTOOL_DIR)/.build

build: $(LIBTOOL_DIR)/.build

clean:
	-rm $(LIBTOOL_DIR)/.build
	$(MAKE) -C $(LIBTOOLF_DIR) uninstall
	$(MAKE) -C $(LIBTOOL_DIR) clean

srcclean:
	rm -rf $(LIBTOOL_DIR)

  
