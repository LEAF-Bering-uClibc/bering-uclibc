# makefile for linux-atm
include $(MASTERMAKEFILE)

ATM_DIR:=linux-atm-2.5.1
ATM_TARGET_DIR:=$(BT_BUILD_DIR)/linuxatm

$(ATM_DIR)/.source:
	zcat $(ATM_SOURCE) | tar -xvf -
#	zcat $(ATM_PATCH1) | patch -d $(ATM_DIR) -p1
	touch $(ATM_DIR)/.source

source: $(ATM_DIR)/.source
                        
$(ATM_DIR)/.configured: $(ATM_DIR)/.source
	perl -i -p -e 's,/usr/include/asm/errno.h,$(BT_STAGING_DIR)/include/asm/errno.h,g' $(ATM_DIR)/src/test/Makefile.in	
	(cd $(ATM_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" \
		./configure --prefix=/usr --sysconfdir=/etc --oldincludedir=$(BT_STAGING_DIR)/include )
	touch $(ATM_DIR)/.configured
                                                                 
$(ATM_DIR)/.build: $(ATM_DIR)/.configured
	mkdir -p $(ATM_TARGET_DIR)
	mkdir -p $(ATM_TARGET_DIR)/sbin
	mkdir -p $(ATM_TARGET_DIR)/usr/bin
	mkdir -p $(ATM_TARGET_DIR)/usr/sbin
	mkdir -p $(ATM_TARGET_DIR)/etc/init.d
	mkdir -p $(ATM_TARGET_DIR)/usr/lib
	mkdir -p $(ATM_TARGET_DIR)/usr/include
	make CC=$(TARGET_CC) -C $(ATM_DIR) 
	-$(BT_STRIP) --strip-unneeded $(ATM_DIR)/src/lib/.libs/libatm.so.1.0.0
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/arpd/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/test/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/maint/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/lane/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/mpoad/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/led/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/ilmid/.libs/*
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(ATM_DIR)/src/sigd/.libs/*
	cp -a $(ATM_DIR)/src/include/atm.h $(ATM_TARGET_DIR)/usr/include;	
	cp -a $(ATM_DIR)/src/include/atmd.h $(ATM_TARGET_DIR)/usr/include;	
	cp -a $(ATM_DIR)/src/include/atmsap.h $(ATM_TARGET_DIR)/usr/include;	
	cp -a $(ATM_DIR)/src/lib/.libs/libatm.so* $(ATM_TARGET_DIR)/usr/lib;
	cp -a $(ATM_DIR)/src/lib/.libs/libatm.a $(ATM_TARGET_DIR)/usr/lib;
	cp -a $(ATM_DIR)/src/arpd/.libs/* $(ATM_TARGET_DIR)/sbin;
	cp -a $(ATM_DIR)/src/test/.libs/aread $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/test/.libs/awrite $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/test/.libs/ttcp_atm $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/maint/.libs/atmdiag $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/maint/.libs/atmdump $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/maint/.libs/saaldump $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/maint/.libs/sonetdiag $(ATM_TARGET_DIR)/usr/bin;
	cp -a $(ATM_DIR)/src/lane/.libs/* $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/mpoad/.libs/mpcd $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/led/.libs/zeppelin $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/ilmid/.libs/ilmid $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/maint/.libs/enitune $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/maint/.libs/atmtcp $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/maint/.libs/atmloop $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/maint/.libs/zntune $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/maint/.libs/esi $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/maint/.libs/atmaddr $(ATM_TARGET_DIR)/usr/sbin;
	cp -a $(ATM_DIR)/src/sigd/.libs/atmsigd $(ATM_TARGET_DIR)/usr/sbin;
	cp -aL atmsigd.conf $(ATM_TARGET_DIR)/etc;
	cp -aL atm.init $(ATM_TARGET_DIR)/etc/init.d/atm;
	cp -a $(ATM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ATM_DIR)/.build

build: $(ATM_DIR)/.build
                                                                                         
clean:
	rm -rf $(ATM_TARGET_DIR)
	(cd $(ATM_DIR); make distclean)
	rm -f $(ATM_DIR)/.build
	rm -f $(ATM_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(ATM_DIR) 
	rm -f $(ATM_DIR)/.source
