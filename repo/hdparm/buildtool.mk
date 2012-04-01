#############################################################
#
# hdparm
#
# $Header:$
#############################################################

include $(MASTERMAKEFILE)

HDPARM_DIR:=$(shell cat DIRNAME)
ifeq ($(HDPARM_DIR),)
HDPARM_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(HDPARM_SOURCE) 2>/dev/null )
endif

HDPARM_TARGET_DIR:=$(BT_BUILD_DIR)/hdparm
export CC=$(TARGET_CC)

$(HDPARM_DIR)/.source:
	zcat $(HDPARM_SOURCE) |  tar -xvf -
	echo $(HDPARM_DIR) > DIRNAME
	touch $(HDPARM_DIR)/.source

source: $(HDPARM_DIR)/.source

$(HDPARM_DIR)/.build: $(HDPARM_DIR)/.source
	mkdir -p $(HDPARM_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) binprefix=/ STRIP=$(GNU_TARGET_NAME)-strip -C $(HDPARM_DIR)
	$(MAKE) binprefix=/ DESTDIR=$(HDPARM_TARGET_DIR) STRIP=$(GNU_TARGET_NAME)-strip -C $(HDPARM_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HDPARM_TARGET_DIR)/sbin/*
	-rm -rf $(HDPARM_TARGET_DIR)/usr
	cp -r $(HDPARM_TARGET_DIR)/* $(BT_STAGING_DIR)/
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

