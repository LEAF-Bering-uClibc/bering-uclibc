#############################################################
#
# keepalived
#
# $Id: buildtool.mk,v 1.2 2010/11/01 11:02:09 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

KEEPALIVED_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(KEEPALIVED_SOURCE) 2>/dev/null )
ifeq ($(KEEPALIVED_DIR),)
KEEPALIVED_DIR:=$(shell cat DIRNAME)
endif
KEEPALIVED_TARGET_DIR:=$(BT_BUILD_DIR)/keepalived


$(KEEPALIVED_DIR)/.source: 
	zcat $(KEEPALIVED_SOURCE) | tar -xvf -
#	(cd $(KEEPALIVED_DIR); zcat ../$(KEEPALIVED_PATCH1) | patch -p1)
	echo $(KEEPALIVED_DIR) > DIRNAME
	touch $(KEEPALIVED_DIR)/.source

$(KEEPALIVED_DIR)/.configured: $(KEEPALIVED_DIR)/.source
	(cd $(KEEPALIVED_DIR); rm -rf config.cache; autoconf; \
		CPPFLAGS="-I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include" \
		LDFLAGS="-L $(BT_STAGING_DIR)/lib -L $(BT_STAGING_DIR)/usr/lib" \
		LD_RUN_PATH="$(BT_STAGING_DIR)/lib:$(BT_STAGING_DIR)/usr/lib" \
		CFLAGS="$(BT_COPT_FLAGS)" \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		./configure \
		--prefix=/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--with-kernel-dir=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE) \
		 );
		touch $(KEEPALIVED_DIR)/.configured

$(KEEPALIVED_DIR)/.build: $(KEEPALIVED_DIR)/.configured
	make CC=$(TARGET_CC) -C $(KEEPALIVED_DIR) all 
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/etc/keepalived	
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/etc/init.d	
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/usr/bin	
	-mkdir -p $(KEEPALIVED_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(KEEPALIVED_DIR)/bin/genhash	
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(KEEPALIVED_DIR)/bin/keepalived	
	cp -aL keepalived.init $(KEEPALIVED_TARGET_DIR)/etc/init.d/keepalived 
	cp -aL keepalived.conf $(KEEPALIVED_TARGET_DIR)/etc/keepalived/keepalived.conf 
	cp -f $(KEEPALIVED_DIR)/bin/genhash $(KEEPALIVED_TARGET_DIR)/usr/bin/
	cp -f $(KEEPALIVED_DIR)/bin/keepalived $(KEEPALIVED_TARGET_DIR)/usr/sbin/
	cp -a -f $(KEEPALIVED_TARGET_DIR)/* $(BT_STAGING_DIR)  	
	touch $(KEEPALIVED_DIR)/.build

source: $(KEEPALIVED_DIR)/.source

build: $(KEEPALIVED_DIR)/.build
	
clean:
	-rm -f $(KEEPALIVED_DIR)/.build
	-rm -f $(KEEPALIVED_DIR)/.configured
	-make -C $(KEEPALIVED_DIR) clean
	-rm -rf $(KEEPALIVED_TARGET_DIR)

srcclean:
	-rm -rf $(KEEPALIVED_DIR) 

