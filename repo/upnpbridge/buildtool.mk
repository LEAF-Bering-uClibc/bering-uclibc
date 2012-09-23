#############################################################
#
# upnpbridge
#
#############################################################

UPNPBRIDGE_DIR:=.
UPNPBRIDGE_TARGET_DIR:=$(BT_BUILD_DIR)/upnpbridge

$(UPNPBRIDGE_DIR)/.source:
	touch $(UPNPBRIDGE_DIR)/.source

$(UPNPBRIDGE_DIR)/.build: $(UPNPBRIDGE_DIR)/.source
	mkdir -p $(UPNPBRIDGE_TARGET_DIR)
	mkdir -p $(UPNPBRIDGE_TARGET_DIR)/usr/sbin
	mkdir -p $(UPNPBRIDGE_TARGET_DIR)/etc/init.d
	mkdir -p $(UPNPBRIDGE_TARGET_DIR)/etc/default
	(cd  $(UPNPBRIDGE_DIR)/contrib; $(TARGET_CC) $(CFLAGS) -o upnpbridge upnpbridge.c)
	mv -f $(UPNPBRIDGE_DIR)/upnpbridge $(UPNPBRIDGE_TARGET_DIR)/usr/sbin
	cp -aL upnpbridge.init $(UPNPBRIDGE_TARGET_DIR)/etc/init.d/upnpbridge
	cp -aL upnpbridge.default $(UPNPBRIDGE_TARGET_DIR)/etc/default/upnpbridge
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(UPNPBRIDGE_TARGET_DIR)/usr/sbin/*
	cp -a  $(UPNPBRIDGE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(UPNPBRIDGE_DIR)/.build

source: $(UPNPBRIDGE_DIR)/.source

build: $(UPNPBRIDGE_DIR)/.build

clean:
	-rm $(UPNPBRIDGE_DIR)/.build
	-rm $(UPNPBRIDGE_DIR)/*.o

srcclean:
	rm -rf $(UPNPBRIDGE_DIR)
