#############################################################
#
# sysmon
#
#############################################################

SYSMON_DIR:=sysmon
SYSMON_TARGET_DIR:=$(BT_BUILD_DIR)/sysmon
export CC=$(TARGET_CC)
CFLAGS=-Os -I$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/include/include
#LDFLAGS=--static
export CFLAGS
#export LDFLAGS
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment

$(SYSMON_DIR)/.source:
	zcat $(SYSMON_SOURCE) |  tar -xvf -
	touch $(SYSMON_DIR)/.source

$(SYSMON_DIR)/.configured: $(SYSMON_DIR)/.source
	touch $(SYSMON_DIR)/.configured

source: $(SYSMON_DIR)/.source

$(SYSMON_DIR)/.build: $(SYSMON_DIR)/.configured
	-mkdir $(SYSMON_TARGET_DIR)
	$(MAKE) CC=$(TARGET_CC) -C $(SYSMON_DIR) sysmon
#	perl -i -p -e 's,DESTDIR =.*,DESTDIR =$(LCD4LINUX_TARGET_DIR),' $(LCD4LINUX_DIR)/Makefile
#	$(BT_STRIP) $(STRIP_OPTIONS) $(LCD4LINUX_TARGET_DIR)/usr/bin/lcd4linux
#	-cp lcd4linux.conf $(LCD4LINUX_TARGET_DIR)/etc/
#	-cp $(LCD4LINUX_TARGET_DIR)/etc/lcd4linux.conf $(BT_STAGING_DIR)/etc/
#	-cp $(LCD4LINUX_TARGET_DIR)/usr/bin/lcd4linux* $(BT_STAGING_DIR)/usr/sbin/
#	-cp lcd4linux $(LCD4LINUX_TARGET_DIR)/etc/init.d
#	-cp lcd4linux $(BT_STAGING_DIR)/etc/init.d
	touch $(SYSMON_DIR)/.build

build: $(SYSMON_DIR)/.build

clean:
	rm -rf $(SYSMON_TARGET_DIR)
	-rm $(SYSMON_DIR)/.build
	$(MAKE) -C $(SYSMON_DIR) clean


srcclean:
	rm -rf $(SYSMON_DIR)

