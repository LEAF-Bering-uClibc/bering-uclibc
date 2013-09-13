################################
# makefile for usbmodeswitch
include $(MASTERMAKEFILE)
################################

USBMODESWITCH_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(USBMODESWITCH_SOURCE) 2>/dev/null )
USBMODESWITCH_TARGET_DIR:=$(BT_BUILD_DIR)/usbmodeswitch

$(USBMODESWITCH_DIR)/.source:
	bzcat $(USBMODESWITCH_SOURCE) | tar -xvf -
	touch $(USBMODESWITCH_DIR)/.source

source: $(USBMODESWITCH_DIR)/.source
                        
$(USBMODESWITCH_DIR)/.configured: $(USBMODESWITCH_DIR)/.source
	sed -i 's:--disable-lineedit :--disable-lineedit --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) :' $(USBMODESWITCH_DIR)/Makefile
	touch $(USBMODESWITCH_DIR)/.configured
                                                                 
$(USBMODESWITCH_DIR)/.build: $(USBMODESWITCH_DIR)/.configured
	mkdir -p $(USBMODESWITCH_TARGET_DIR)
	( cd $(USBMODESWITCH_DIR) ; export DESTDIR=$(USBMODESWITCH_TARGET_DIR); export CC=$(TARGET_CC); \
	export LD=$(TARGET_LD); make install-static )
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(USBMODESWITCH_TARGET_DIR)/usr/sbin/usb_modeswitch
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(USBMODESWITCH_TARGET_DIR)/usr/sbin/usb_modeswitch_dispatcher
	cp -a $(USBMODESWITCH_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(USBMODESWITCH_DIR)/.build

build: $(USBMODESWITCH_DIR)/.build
                                                                                         
clean:
	rm -rf $(USBMODESWITCH_TARGET_DIR)
	rm -rf $(USBMODESWITCH_DIR)/.build
	rm -rf $(USBMODESWITCH_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(USBMODESWITCH_DIR)
	rm -rf $(USBMODESWITCH_DIR)/.source
