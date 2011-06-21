#############################################################
#
# hdparm
#
# $Header:$
#############################################################

include $(MASTERMAKEFILE)

HDPARM_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(HDPARM_SOURCE) 2>/dev/null )
ifeq ($(HDPARM_DIR),)
HDPARM_DIR:=$(shell cat DIRNAME)
endif

HDPARM_TARGET_DIR:=$(BT_BUILD_DIR)/hdparm
export CC=$(TARGET_CC)

$(HDPARM_DIR)/.source: 
	zcat $(HDPARM_SOURCE) |  tar -xvf - 
	#zcat $(HDPARM_PATCH1) | patch -d $(HDPARM_DIR) -p1	
	#perl -i -p -e 's,-O2,-Os,g' $(HDPARM_DIR)/Makefile
	echo $(HDPARM_DIR) > DIRNAME
	touch $(HDPARM_DIR)/.source

source: $(HDPARM_DIR)/.source

$(HDPARM_DIR)/.build: $(HDPARM_DIR)/.source
	mkdir -p $(HDPARM_TARGET_DIR)
	$(MAKE) CC=$(TARGET_CC) binprefix=/ -C $(HDPARM_DIR) 
	$(MAKE) CC=$(TARGET_CC) binprefix=/ DESTDIR=$(HDPARM_TARGET_DIR) -C $(HDPARM_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HDPARM_TARGET_DIR)/sbin/hdparm
	mkdir -p $(BT_STAGING_DIR)/sbin
	-cp $(HDPARM_TARGET_DIR)/sbin/hdparm $(BT_STAGING_DIR)/sbin/ 
	touch $(HDPARM_DIR)/.build
	
build: $(HDPARM_DIR)/.build

clean:
	rm -rf $(HDPARM_TARGET_DIR)
	-rm $(HDPARM_DIR)/.build
	$(MAKE) -C $(HDPARM_DIR) clean
	-rm $(BT_STAGING_DIR)/sbin/hdparm
	

srcclean:
	rm -rf $(HDPARM_DIR)
	-rm DIRNAME

