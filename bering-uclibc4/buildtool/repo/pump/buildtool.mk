# makefile for pump
include $(MASTERMAKEFILE)

PUMP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(PUMP_SOURCE) 2>/dev/null )
ifeq ($(PUMP_DIR),)
PUMP_DIR:=$(shell cat DIRNAME)
endif
PUMP_TARGET_DIR:=$(BT_BUILD_DIR)/pump


$(PUMP_DIR)/.source:
	tar xvzf $(PUMP_SOURCE)
	zcat $(PUMP_PATCH1) | patch -d $(PUMP_DIR) -p1
	echo $(PUMP_DIR) > DIRNAME
	touch $(PUMP_DIR)/.source

source: $(PUMP_DIR)/.source
                        
$(PUMP_DIR)/.build: $(PUMP_DIR)/.source
	mkdir -p $(PUMP_TARGET_DIR)
	mkdir -p $(PUMP_TARGET_DIR)/etc/
	mkdir -p $(PUMP_TARGET_DIR)/sbin
	make -C $(PUMP_DIR) CC=$(TARGET_CC) LD_LIBRARY_PATH="$(BT_STAGING_DIR)/lib:$(BT_STAGING_DIR)/usr/lib" \
	DEB_CFLAGS="$(BT_COPT_FLAGS) -I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include" pump
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PUMP_DIR)/pump
	cp -a $(PUMP_DIR)/pump $(PUMP_TARGET_DIR)/sbin
	cp -aL pump.shorewall $(PUMP_TARGET_DIR)/etc
	cp -aL pump.conf $(PUMP_TARGET_DIR)/etc
	cp -a $(PUMP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PUMP_DIR)/.build


build: $(PUMP_DIR)/.build
                                                                                         
clean:
	make -C $(PUMP_DIR) clean
	rm -rf $(PUMP_DIR)/.build
	rm -rf $(PUMP_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(PUMP_DIR)
