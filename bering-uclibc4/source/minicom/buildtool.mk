# makefile for minicom
include $(MASTERMAKEFILE)

MINICOM_DIR:=minicom-2.1
MINICOM_TARGET_DIR:=$(BT_BUILD_DIR)/minicom

$(MINICOM_DIR)/.source:
	zcat $(MINICOM_SOURCE) | tar -xvf -
	cat $(MINICOM_PATCH) | patch -p1 -d $(MINICOM_DIR)
	touch $(MINICOM_DIR)/.source

source: $(MINICOM_DIR)/.source

$(MINICOM_DIR)/.configured: $(MINICOM_DIR)/.source
	(cd $(MINICOM_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure --disable-nls --prefix=/usr)
	touch $(MINICOM_DIR)/.configured
                        
$(MINICOM_DIR)/.build: $(MINICOM_DIR)/.configured
	mkdir -p $(MINICOM_TARGET_DIR)
	mkdir -p $(MINICOM_TARGET_DIR)/usr/bin
	make CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" -C $(MINICOM_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(MINICOM_DIR)/minicom
	cp -a $(MINICOM_DIR)/src/minicom $(MINICOM_TARGET_DIR)/usr/bin
	cp -a $(MINICOM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(MINICOM_DIR)/.build

build: $(MINICOM_DIR)/.build
                                                                                         
clean:
	make -C $(MINICOM_DIR) clean
	rm -rf $(MINICOM_TARGET_DIR)
	rm -f $(MINICOM_DIR)/.build
	rm -f $(MINICOM_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(MINICOM_DIR) 
	rm -f $(MINICOM_DIR)/.source
