#############################################################
#
# automake
#
#############################################################

include $(MASTERMAKEFILE)
AUTOMAKE_DIR_LATEST:=automake-1.11.1
AUTOMAKE_DIR_4:=automake-1.4-p6
export CC=$(TARGET_CC)
PERLVER=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)

CFLAGS=-Os -s -I$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/include/include
export CFLAGS

$(AUTOMAKE_DIR_LATEST)/.source: 
	bzcat $(AUTOMAKE_SOURCE_LATEST) |  tar -xvf - 	
	touch $(AUTOMAKE_DIR_LATEST)/.source

$(AUTOMAKE_DIR_4)/.source:
	zcat $(AUTOMAKE_SOURCE_4) |  tar -xvf - 	
	touch $(AUTOMAKE_DIR_4)/.source


$(AUTOMAKE_DIR_LATEST)/.configured: $(AUTOMAKE_DIR_LATEST)/.source
	(export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	cd $(AUTOMAKE_DIR_LATEST); rm -rf config.cache; \
	CC=$(TARGET_CC)  PERL="$(BT_STAGING_DIR)/usr/bin/perl" \
		./configure \
		--prefix=$(BT_STAGING_DIR) \
		--target=$(BT_TARGET_NAME) \
		--host=$(BT_TARGET_NAME) \
		--build=$(BT_HOST_NAME) );
	touch $(AUTOMAKE_DIR_LATEST)/.configured


$(AUTOMAKE_DIR_4)/.configured:$(AUTOMAKE_DIR_4)/.source
	(export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	cd $(AUTOMAKE_DIR_4); rm -rf config.cache; \
	CC=$(TARGET_CC)  PERL="$(BT_STAGING_DIR)/usr/bin/perl" \
		./configure \
		--prefix=$(BT_STAGING_DIR) \
		--target=$(BT_TARGET_NAME) \
		--host=$(BT_TARGET_NAME) \
		--build=$(BT_HOST_NAME) );
	touch $(AUTOMAKE_DIR_4)/.configured


source: $(AUTOMAKE_DIR_4)/.source $(AUTOMAKE_DIR_LATEST)/.source 

build: $(AUTOMAKE_DIR_4)/.configured $(AUTOMAKE_DIR_LATEST)/.configured 
	$(MAKE) CC=$(TARGET_CC) -C $(AUTOMAKE_DIR_4) 
	$(MAKE) CC=$(TARGET_CC) -C $(AUTOMAKE_DIR_4) install
	$(MAKE) CC=$(TARGET_CC) -C $(AUTOMAKE_DIR_LATEST) 
	$(MAKE) CC=$(TARGET_CC) -C $(AUTOMAKE_DIR_LATEST) install
	

clean:
	$(MAKE) -C $(AUTOMAKE_DIR_LATEST) uninstall
	$(MAKE) -C $(AUTOMAKE_DIR_LATEST) clean
	$(MAKE) -C $(AUTOMAKE_DIR_4) uninstall
	$(MAKE) -C $(AUTOMAKE_DIR_4) clean

srcclean:
	rm -rf $(AUTOMAKE_DIR_LATEST)
	rm -rf $(AUTOMAKE_DIR_4)
