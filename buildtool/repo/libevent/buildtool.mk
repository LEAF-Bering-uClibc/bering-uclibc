#############################################################
#
# buildtool makefile for libevent
#
#############################################################

include $(MASTERMAKEFILE)

LIBEVENT_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBEVENT_SOURCE) 2>/dev/null )
ifeq ($(LIBEVENT_DIR),)
LIBEVENT_DIR:=$(shell cat DIRNAME)
endif
LIBEVENT_TARGET_DIR:=$(BT_BUILD_DIR)/libevent

$(LIBEVENT_DIR)/.source:
	zcat $(LIBEVENT_SOURCE) | tar -xvf -
	echo $(LIBEVENT_DIR) > DIRNAME
	touch $(LIBEVENT_DIR)/.source

source: $(LIBEVENT_DIR)/.source
                        
$(LIBEVENT_DIR)/.configured: $(LIBEVENT_DIR)/.source
	(cd $(LIBEVENT_DIR) ; CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure)
	touch $(LIBEVENT_DIR)/.configured
                                                                 
$(LIBEVENT_DIR)/.build: $(LIBEVENT_DIR)/.configured
	mkdir -p $(LIBEVENT_TARGET_DIR)
	make -C $(LIBEVENT_DIR) all
	$(BT_STRIP)  --strip-unneeded $(LIBEVENT_DIR)/.libs/*.so
	mkdir -p $(LIBEVENT_TARGET_DIR)/usr/lib
	mkdir -p $(LIBEVENT_TARGET_DIR)/usr/include
	cp -a $(LIBEVENT_DIR)/.libs/*so* $(LIBEVENT_TARGET_DIR)/usr/lib
	cp -a $(LIBEVENT_DIR)/event.h $(LIBEVENT_TARGET_DIR)/usr/include
	cp -a $(LIBEVENT_DIR)/event-config.h $(LIBEVENT_TARGET_DIR)/usr/include
	cp -a $(LIBEVENT_DIR)/evutil.h $(LIBEVENT_TARGET_DIR)/usr/include
	cp -a -f $(LIBEVENT_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a -f $(LIBEVENT_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include	
	touch $(LIBEVENT_DIR)/.build

build: $(LIBEVENT_DIR)/.build
                                                                                         
clean:
	make -C $(LIBEVENT_DIR) clean
	rm -rf $(LIBEVENT_TARGET_DIR)
	rm -rf $(LIBEVENT_DIR)/.build
	rm -rf $(LIBEVENT_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(LIBEVENT_DIR) 
	rm -rf $(LIBEVENT_DIR)/.source
	-rm DIRNAME
