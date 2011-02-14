# makefile for wpasupplicant
include $(MASTERMAKEFILE)

WPA_DIR:=wpa_supplicant-0.5.11
WPA_TARGET_DIR:=$(BT_BUILD_DIR)/wpasupplicant


$(WPA_DIR)/.source:
	zcat $(WPA_SOURCE) | tar -xvf -
#	cat $(WPA_PATCH) | patch -d $(WPA_DIR) -p1
	touch $(WPA_DIR)/.source

source: $(WPA_DIR)/.source
                        
$(WPA_DIR)/.build:
	mkdir -p $(WPA_TARGET_DIR)
	mkdir -p $(WPA_TARGET_DIR)/usr/sbin
	mkdir -p $(WPA_TARGET_DIR)/etc
	mkdir -p $(WPA_TARGET_DIR)/etc/default
	mkdir -p $(WPA_TARGET_DIR)/etc/init.d
	cp -aL .config $(WPA_DIR)/
	( cd $(WPA_DIR) ; export CFLAGS="$(BT_COPT_FLAGS) -MMD -Wall -g -I$(BT_STAGING_DIR)/usr/include" ; \
	export LIBS=-L$(BT_STAGING_DIR)/usr/lib ; make CC=$(TARGET_CC) ) ;
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(WPA_DIR)/wpa_cli
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(WPA_DIR)/wpa_passphrase
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(WPA_DIR)/wpa_supplicant
	cp -a $(WPA_DIR)/wpa_cli $(WPA_TARGET_DIR)/usr/sbin	
	cp -a $(WPA_DIR)/wpa_passphrase $(WPA_TARGET_DIR)/usr/sbin	
	cp -a $(WPA_DIR)/wpa_supplicant $(WPA_TARGET_DIR)/usr/sbin	
	cp -aL wpa_supplicant.conf $(WPA_TARGET_DIR)/etc	
	cp -aL wpasupplicant.default $(WPA_TARGET_DIR)/etc/default/wpasupplicant
	cp -aL wpasupplicant.init $(WPA_TARGET_DIR)/etc/init.d/wpasupplicant
	cp -a $(WPA_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(WPA_DIR)/.build

build: $(WPA_DIR)/.build
                                                                                         
clean:
	make -C $(WPA_DIR) clean
	rm -rf $(WPA_TARGET_DIR)
	rm -f $(WPA_DIR)/.build
	rm -f $(WPA_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(WPA_DIR) 
	rm -f $(WPA_DIR)/.source
