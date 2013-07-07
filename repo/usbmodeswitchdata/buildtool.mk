#################################
#
# makefile for usbmodeswitchdata
#
#################################

USBMODESWITCHDATA_DIR:=usb-modeswitch-data-20130610
USBMODESWITCHDATA_TARGET_DIR:=$(BT_BUILD_DIR)/usbmodeswitchdata

$(USBMODESWITCHDATA_DIR)/.source:
	bzcat $(USBMODESWITCHDATA_SOURCE) | tar -xvf -
	touch $(USBMODESWITCHDATA_DIR)/.source

source: $(USBMODESWITCHDATA_DIR)/.source

$(USBMODESWITCHDATA_DIR)/.build: $(USBMODESWITCHDATA_DIR)/.source
	mkdir -p $(USBMODESWITCHDATA_TARGET_DIR)
	( cd $(USBMODESWITCHDATA_DIR) ; export DESTDIR=$(USBMODESWITCHDATA_TARGET_DIR); make install )
	cp -a $(USBMODESWITCHDATA_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(USBMODESWITCHDATA_DIR)/.build

build: $(USBMODESWITCHDATA_DIR)/.build
                                                                                         
clean:
	rm -rf $(USBMODESWITCHDATA_TARGET_DIR)
	rm -rf $(USBMODESWITCHDATA_DIR)/.build

srcclean: clean
	rm -rf $(USBMODESWITCHDATA_DIR)
	rm -rf $(USBMODESWITCHDATA_DIR)/.source
