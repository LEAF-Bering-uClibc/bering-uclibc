################################################
#  makefile for ddclient
################################################

DDCLIENT_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(DDCLIENT_SOURCE) 2>/dev/null )
DDCLIENT_TARGET_DIR:=$(BT_BUILD_DIR)/ddclient

$(DDCLIENT_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(DDCLIENT_SOURCE)
	touch $(DDCLIENT_DIR)/.source

$(DDCLIENT_DIR)/.build: $(DDCLIENT_DIR)/.source
#	mkdir -p $(DDCLIENT_TARGET_DIR)
	mkdir -p $(DDCLIENT_TARGET_DIR)/etc/ddclient
	mkdir -p $(DDCLIENT_TARGET_DIR)/etc/cron.d
	mkdir -p $(DDCLIENT_TARGET_DIR)/usr/sbin
#	mkdir -p $(DDCLIENT_TARGET_DIR)/var/cache/ddclient

	cp -a $(DDCLIENT_DIR)/sample-etc_ddclient.conf $(DDCLIENT_TARGET_DIR)/etc/ddclient/ddclient.conf
	cp -a $(DDCLIENT_DIR)/sample-etc_cron.d_ddclient $(DDCLIENT_TARGET_DIR)/etc/cron.d/ddclient
	cp -a $(DDCLIENT_DIR)/ddclient $(DDCLIENT_TARGET_DIR)/usr/sbin/
	cp -a $(DDCLIENT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DDCLIENT_DIR)/.build

source: $(DDCLIENT_DIR)/.source

build: $(DDCLIENT_DIR)/.build

clean:
	-rm $(DDCLIENT_DIR)/.build
	-rm -r $(DDCLIENT_BUILD_DIR)

srcclean:
	rm -rf $(DDCLIENT_DIR)
