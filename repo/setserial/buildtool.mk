include $(MASTERMAKEFILE)
SETSERIAL_DIR:=setserial-2.17
SETSERIAL_TARGET_DIR:=$(BT_BUILD_DIR)/setserial

$(SETSERIAL_DIR)/.source:
	zcat $(SETSERIAL_SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(SETSERIAL_DIR)
	touch $(SETSERIAL_DIR)/.source

$(SETSERIAL_DIR)/.configured: $(SETSERIAL_DIR)/.source
	cd $(SETSERIAL_DIR); CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/usr
	touch $(SETSERIAL_DIR)/.configured

$(SETSERIAL_DIR)/.build: $(SETSERIAL_DIR)/.configured
	$(MAKE) $(MAKEOPTS) -C $(SETSERIAL_DIR)
	mkdir -p $(BT_STAGING_DIR)/bin
	mkdir -p $(BT_STAGING_DIR)/etc
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	cp -a -f $(SETSERIAL_DIR)/setserial $(BT_STAGING_DIR)/bin
	cp -a -f $(SETSERIAL_DIR)/serial.conf $(BT_STAGING_DIR)/etc/serial.conf
	cp -aL -f $(SETSERIAL_INITD) $(BT_STAGING_DIR)/etc/init.d/setserial.sh
	touch $(SETSERIAL_DIR)/.build

source: $(SETSERIAL_DIR)/.source

build: $(SETSERIAL_DIR)/.build

clean:
	-rm $(SETSERIAL_DIR)/.build
	rm -rf $(SETSERIAL_TARGET_DIR)
	$(MAKE) -C $(SETSERIAL_DIR) clean
	rm -f $(BT_STAGING_DIR)/etc/init.d/setserial.sh
	rm -f $(BT_STAGING_DIR)/etc/serial.conf
	rm -f $(BT_STAGING_DIR)/bin/setserial

srcclean:
	rm -rf $(SETSERIAL_DIR)
