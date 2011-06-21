#############################################################
#
# autoconf
#
#############################################################

include $(MASTERMAKEFILE)
AUTOCONF_DIR:=autoconf-2.68
export CC=$(TARGET_CC)
CFLAGS=-Os -s -I$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/include/include
export CFLAGS
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment 
PERLVER=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5) 


$(AUTOCONF_DIR)/.source: 		
	bzcat $(AUTOCONF_SOURCE) |  tar -xvf - 	
	touch $(AUTOCONF_DIR)/.source


$(AUTOCONF_DIR)/.configured: $(AUTOCONF_DIR)/.source
	(cd $(AUTOCONF_DIR); rm -rf config.cache; CC=$(TARGET_CC)  \
	./configure \
		--prefix=$(BT_STAGING_DIR) );
	touch $(AUTOCONF_DIR)/.configured


source: $(AUTOCONF_DIR)/.source

build: $(AUTOCONF_DIR)/.configured
	(export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	$(MAKE) CC=$(TARGET_CC) -C $(AUTOCONF_DIR))
	$(MAKE) CC=$(TARGET_CC) -C $(AUTOCONF_DIR) install
	

clean:
	-rm $(AUTOCONF_DIR)/.configured
	$(MAKE) -C $(AUTOCONF_DIR) uninstall
	$(MAKE) -C $(AUTOCONF_DIR) clean
  

srcclean:
	rm -rf $(AUTOCONF_DIR)
	