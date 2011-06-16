# makefile for smartmon
include $(MASTERMAKEFILE)

SMARTMON_DIR:=smartmontools-5.36
SMARTMON_TARGET_DIR:=$(BT_BUILD_DIR)/smartmon

$(SMARTMON_DIR)/.source:
	zcat $(SMARTMON_SOURCE) | tar -xvf -
	touch $(SMARTMON_DIR)/.source

source: $(SMARTMON_DIR)/.source

$(SMARTMON_DIR)/.configured: $(SMARTMON_DIR)/.source
	(cd $(SMARTMON_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" \
	./configure --prefix=/usr --sysconfdir=/etc --with-initscriptdir=/etc/init.d)
	touch $(SMARTMON_DIR)/.configured
                        
$(SMARTMON_DIR)/.build: $(SMARTMON_DIR)/.configured
	mkdir -p $(SMARTMON_TARGET_DIR)
	mkdir -p $(SMARTMON_TARGET_DIR)/usr/sbin
	mkdir -p $(SMARTMON_TARGET_DIR)/etc/default
	mkdir -p $(SMARTMON_TARGET_DIR)/etc/init.d
	make CC=$(TARGET_CC) -C $(SMARTMON_DIR)
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SMARTMON_DIR)/smartd
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SMARTMON_DIR)/smartctl
	cp -a $(SMARTMON_DIR)/smartd $(SMARTMON_TARGET_DIR)/usr/sbin
	cp -a $(SMARTMON_DIR)/smartctl $(SMARTMON_TARGET_DIR)/usr/sbin	
	cp -aL smartd.init $(SMARTMON_TARGET_DIR)/etc/init.d/smartd
	cp -aL smartd.default $(SMARTMON_TARGET_DIR)/etc/default/smartd
	cp -aL smartd.conf $(SMARTMON_TARGET_DIR)/etc/
	cp -a $(SMARTMON_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SMARTMON_DIR)/.build

build: $(SMARTMON_DIR)/.build
                                                                                         
clean:
	make -C $(SMARTMON_DIR) clean
	rm -rf $(SMARTMON_TARGET_DIR)
	rm -f $(SMARTMON_DIR)/.build
	rm -f $(SMARTMON_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(SMARTMON_DIR) 
	rm -f $(SMARTMON_DIR)/.source
