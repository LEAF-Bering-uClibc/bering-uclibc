#############################################################
#
# cron
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:26 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
CRON_DIR:=cron-3.0pl1.orig
CRON_TARGET_DIR:=$(BT_BUILD_DIR)/cron


$(CRON_DIR)/.source:
	zcat $(CRON_SOURCE) |  tar -xvf -
	zcat $(CRON_PATCH1) | patch -d $(CRON_DIR) -p1
	touch $(CRON_DIR)/.source

$(CRON_DIR)/.build: $(CRON_DIR)/.source
	mkdir -p $(CRON_TARGET_DIR)
	-mkdir -p $(BT_STAGING_DIR)/usr/sbin
	$(MAKE) $(MAKEOPTS) -C $(CRON_DIR) 	\
		CC=$(TARGET_CC) OPTIM="$(CFLAGS) -Wall -Wno-comment" \
		DEBUG_DEFS="-DDEBUGGING=0"
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(CRON_DIR)/cron
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(CRON_DIR)/crontab
	cp -a  $(CRON_DIR)/cron  $(CRON_TARGET_DIR)/
	cp -a  $(CRON_TARGET_DIR)/* $(BT_STAGING_DIR)/usr/sbin
	touch $(CRON_DIR)/.build

source: $(CRON_DIR)/.source

build: $(CRON_DIR)/.build

clean:
	-rm $(CRON_DIR)/.build
	-$(MAKE) -C $(CRON_DIR) clean

srcclean:
	rm -rf $(CRON_DIR)
