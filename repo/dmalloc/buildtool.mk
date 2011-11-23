#############################################################
#
# dmalloc
#
#############################################################

include $(MASTERMAKEFILE)
DMALLOC_DIR:=dmalloc-5.3.0
export CC=$(TARGET_CC)
CFLAGS=-Os -s -I$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/include/include
export CFLAGS
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment


$(DMALLOC_DIR)/.source:
	zcat $(DMALLOC_SOURCE) |  tar -xvf -
	touch $(DMALLOC_DIR)/.source


$(DMALLOC_DIR)/.configured: $(DMALLOC_DIR)/.source
	(cd $(DMALLOC_DIR); rm -rf config.cache; CC=$(TARGET_CC)  \
	./configure \
		--prefix=$(BT_STAGING_DIR) );
	touch $(DMALLOC_DIR)/.configured


source: $(DMALLOC_DIR)/.source

build: $(DMALLOC_DIR)/.configured
	-mkdir $(DMALLOC_TARGET_DIR)
	$(MAKE) CC=$(TARGET_CC) -C $(DMALLOC_DIR)
	$(MAKE) CC=$(TARGET_CC) -C $(DMALLOC_DIR) install


clean:
	-rm $(DMALLOC_DIR)/.configured
	$(MAKE) -C $(DMALLOC_DIR) uninstall
	$(MAKE) -C $(DMALLOC_DIR) clean


srcclean:
	rm -rf $(DMALLOC_DIR)