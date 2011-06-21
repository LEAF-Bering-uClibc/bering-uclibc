# makefile for squid
include $(MASTERMAKEFILE)

#alias gcc=$(BT_STAGING_DIR)/usr/local/kgcc/bin/gcc

SQUID_DIR:=squid-2.5.STABLE14
SQUID_TARGET_DIR:=$(BT_BUILD_DIR)/squid

$(SQUID_DIR)/.source:
	zcat $(SQUID_SOURCE) | tar -xvf -
	touch $(SQUID_DIR)/.source

source: $(SQUID_DIR)/.source
                        
$(SQUID_DIR)/.configured: $(SQUID_DIR)/.source
	(cd $(SQUID_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure --with-ldflags=-s \
	--sysconfdir=/etc/squid --prefix= \
	--disable-ident-lookups --disable-internal-dns \
	--exec-prefix=/usr --libexecdir=/usr/bin \
	--enable-snmp --target=i386-pc-linux-gnu \
	--datadir=/etc/squid \
	--disable-dependency-tracking --disable-wccp \
	--enable-poll --enable-delay-pools \
	--enable-default-err-language=English \
	--enable-err-languages="English" )
	touch $(SQUID_DIR)/.configured
                                                                 
$(SQUID_DIR)/.build: $(SQUID_DIR)/.configured
	mkdir -p $(SQUID_TARGET_DIR)
	mkdir -p $(SQUID_TARGET_DIR)/etc/init.d	
	mkdir -p $(SQUID_TARGET_DIR)/etc/cron.daily	
	mkdir -p $(SQUID_TARGET_DIR)/etc/squid	
	mkdir -p $(SQUID_TARGET_DIR)/etc/squid/errors/English
	mkdir -p $(SQUID_TARGET_DIR)/etc/squid/icons	
	mkdir -p $(SQUID_TARGET_DIR)/usr/sbin	
	mkdir -p $(SQUID_TARGET_DIR)/usr/bin
	mkdir -p $(SQUID_TARGET_DIR)/usr/lib/cgi-bin		
#       breaks patch
#	make CFLAGS="$(BT_COPT_FLAGS)" -C $(SQUID_DIR) all
	make CFLAGS="-Wall" -C $(SQUID_DIR) all	
	chmod 644 $(SQUID_DIR)/icons/an*	
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SQUID_DIR)/src/squid	
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SQUID_DIR)/src/squidclient
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SQUID_DIR)/src/dnsserver
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SQUID_DIR)/src/unlinkd		
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SQUID_DIR)/src/cachemgr.cgi			
	cp -aL squid.init $(SQUID_TARGET_DIR)/etc/init.d/squid
	cp -aL squid.conf $(SQUID_TARGET_DIR)/etc/squid
	cp -aL ok_domains $(SQUID_TARGET_DIR)/etc/squid	
	cp -a $(SQUID_DIR)/src/mib.txt $(SQUID_TARGET_DIR)/etc/squid
	cp -aL squid.daily $(SQUID_TARGET_DIR)/etc/cron.daily/squid	
	cp -a $(SQUID_DIR)/src/mime.conf.default $(SQUID_TARGET_DIR)/etc/squid/mime.conf	
	cp -a $(SQUID_DIR)/errors/English/* $(SQUID_TARGET_DIR)/etc/squid/errors/English	
	cp -a $(SQUID_DIR)/icons/*.gif $(SQUID_TARGET_DIR)/etc/squid/icons	
	cp -a $(SQUID_DIR)/src/squid $(SQUID_TARGET_DIR)/usr/sbin
	cp -a $(SQUID_DIR)/src/squidclient $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/src/dnsserver $(SQUID_TARGET_DIR)/usr/bin	
	cp -a $(SQUID_DIR)/src/unlinkd $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/scripts/RunAccel $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/scripts/RunCache $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/src/cachemgr.cgi $(SQUID_TARGET_DIR)/usr/lib/cgi-bin
	cp -a $(SQUID_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SQUID_DIR)/.build

build: $(SQUID_DIR)/.build
                                                                                         
clean:
	make -C $(SQUID_DIR) clean
	rm -rf $(SQUID_TARGET_DIR)
	rm -rf $(SQUID_DIR)/.build
	rm -rf $(SQUID_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(SQUID_DIR) 
	rm -rf $(SQUID_DIR)/.source
