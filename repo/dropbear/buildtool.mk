# makefile for dropbear
include $(MASTERMAKEFILE)

DROPBEAR_DIR:=dropbear-0.53
DROPBEAR_TARGET_DIR:=$(BT_BUILD_DIR)/dropbear

$(DROPBEAR_DIR)/.source:
	zcat $(DROPBEAR_SOURCE) | tar -xvf -
	touch $(DROPBEAR_DIR)/.source

source: $(DROPBEAR_DIR)/.source
                        
$(DROPBEAR_DIR)/.configured: $(DROPBEAR_DIR)/.source
	(cd $(DROPBEAR_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_CC) \
	./configure --prefix=/usr --disable-zlib --disable-lastlog --enable-bundled-libtom)
	cp options.h $(DROPBEAR_DIR)
	touch $(DROPBEAR_DIR)/.configured
                                                                 
$(DROPBEAR_DIR)/.build: $(DROPBEAR_DIR)/.configured
	mkdir -p $(DROPBEAR_TARGET_DIR)
	mkdir -p $(DROPBEAR_TARGET_DIR)/etc/init.d	
	mkdir -p $(DROPBEAR_TARGET_DIR)/etc/default	
	mkdir -p $(DROPBEAR_TARGET_DIR)/usr/bin	
	mkdir -p $(DROPBEAR_TARGET_DIR)/usr/sbin	
	$(MAKE) PROGRAMS="dropbear dropbearkey scp" MULTI=1 STATIC=0 SCPPROGRESS=0 -C $(DROPBEAR_DIR)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DROPBEAR_DIR)/dropbearmulti
	cp -a $(DROPBEAR_DIR)/dropbearmulti $(DROPBEAR_TARGET_DIR)/usr/sbin
	cp -aL dropbear.init $(DROPBEAR_TARGET_DIR)/etc/init.d/dropbear
	cp -aL dropbear.conf $(DROPBEAR_TARGET_DIR)/etc/default/dropbear

	$(MAKE) -C $(DROPBEAR_DIR) clean

	$(MAKE) PROGRAMS="dbclient" MULTI=0 STATIC=0 -C $(DROPBEAR_DIR)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DROPBEAR_DIR)/dbclient
	cp -a $(DROPBEAR_DIR)/dbclient $(DROPBEAR_TARGET_DIR)/usr/bin
	cp -a $(DROPBEAR_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DROPBEAR_DIR)/.build

build: $(DROPBEAR_DIR)/.build
                                                                                         
clean:
	make -C $(DROPBEAR_DIR) clean
	rm -rf $(DROPBEAR_TARGET_DIR)
	rm $(DROPBEAR_DIR)/.build
	rm $(DROPBEAR_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(DROPBEAR_DIR) 
	rm $(DROPBEAR_DIR)/.source