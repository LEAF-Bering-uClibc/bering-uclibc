# makefile for tinyproxy
include $(MASTERMAKEFILE)

TINYPROXY_DIR:=tinyproxy-1.8.3
TINYPROXY_TARGET_DIR:=$(BT_BUILD_DIR)/tinyproxy
PERLVER=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5 2>/dev/null)

$(TINYPROXY_DIR)/.source:
	bzcat $(TINYPROXY_SOURCE) | tar -xvf -
	cat $(TINYPROXY_PATCH) | patch -p1 -d $(TINYPROXY_DIR)
	touch $(TINYPROXY_DIR)/.source

source: $(TINYPROXY_DIR)/.source
                        
$(TINYPROXY_DIR)/.configured: $(TINYPROXY_DIR)/.source
	([ -$(PERLVER) = - ] || export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	cd $(TINYPROXY_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./autogen.sh --prefix=/usr \
	--sysconfdir=/etc/tinyproxy --enable-xtinyproxy \
	--bindir=/usr/sbin --enable-transparent-proxy )
	touch $(TINYPROXY_DIR)/.configured
                                                                 
$(TINYPROXY_DIR)/.build: $(TINYPROXY_DIR)/.configured
	mkdir -p $(TINYPROXY_TARGET_DIR)
	mkdir -p $(TINYPROXY_TARGET_DIR)/etc/tinyproxy
	mkdir -p $(TINYPROXY_TARGET_DIR)/etc/init.d
	mkdir -p $(TINYPROXY_TARGET_DIR)/etc/cron.daily		
	mkdir -p $(TINYPROXY_TARGET_DIR)/usr/sbin	
	make -C $(TINYPROXY_DIR)/src all
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(TINYPROXY_DIR)/src/tinyproxy	
	cp -aL tinyproxy.init $(TINYPROXY_TARGET_DIR)/etc/init.d/tinyproxy
	cp -aL tinyproxy.conf $(TINYPROXY_TARGET_DIR)/etc/tinyproxy/tinyproxy.conf
	cp -aL filter $(TINYPROXY_TARGET_DIR)/etc/tinyproxy/filter	
	cp -aL tinyproxy.cron $(TINYPROXY_TARGET_DIR)/etc/cron.daily/tinyproxy
	cp -a $(TINYPROXY_DIR)/src/tinyproxy $(TINYPROXY_TARGET_DIR)/usr/sbin
	cp -a $(TINYPROXY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TINYPROXY_DIR)/.build

build: $(TINYPROXY_DIR)/.build
                                                                                         
clean:
#	make -C $(TINYPROXY_DIR) clean
	rm -rf $(TINYPROXY_TARGET_DIR)
	rm -rf $(TINYPROXY_DIR)/.build
	rm -rf $(TINYPROXY_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(TINYPROXY_DIR) 
	rm -rf $(TINYPROXY_DIR)/.source
