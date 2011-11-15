# makefile for ntp
include $(MASTERMAKEFILE)

NTP_DIR:=ntp-4.2.6
NTP_TARGET_DIR:=$(BT_BUILD_DIR)/ntp

$(NTP_DIR)/.source:
	zcat $(NTP_SOURCE) | tar -xvf -
	cat $(NTP_PATCH1) | patch -d $(NTP_DIR) -p1
	touch $(NTP_DIR)/.source

source: $(NTP_DIR)/.source
                        
$(NTP_DIR)/.configured: $(NTP_DIR)/.source
	(cd $(NTP_DIR) ; ./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--without-openssl-libdir \
	--without-openssl-incdir \
	--without-crypto \
	--without-ntpsnmpd \
	--enable-ipv6 \
	--disable-all-clocks \
	--disable-parse-clocks \
	--disable-debugging \
	--enable-LOCAL-CLOCK \
	--sysconfdir=/var/lib/ntp \
	--disable-errorcache );
	touch $(NTP_DIR)/.configured

#	--host=$(GNU_HOST_NAME) \
#	--build=$(GNU_HOST_NAME) \

                                                                 
$(NTP_DIR)/.build: $(NTP_DIR)/.configured
	mkdir -p $(NTP_TARGET_DIR)
	mkdir -p $(NTP_TARGET_DIR)/etc/init.d
	mkdir -p $(NTP_TARGET_DIR)/etc/default
	mkdir -p $(NTP_TARGET_DIR)/etc/cron.daily	
	mkdir -p $(NTP_TARGET_DIR)/etc/cron.weekly			
	mkdir -p $(NTP_TARGET_DIR)/etc/network/if-up.d			
	mkdir -p $(NTP_TARGET_DIR)/usr/sbin		
	make $(MAKEOPTS) -C $(NTP_DIR) all
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NTP_DIR)/ntpd/ntpd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NTP_DIR)/ntpq/ntpq
	cp -a $(NTP_DIR)/ntpd/ntpd $(NTP_TARGET_DIR)/usr/sbin
	cp -a $(NTP_DIR)/ntpq/ntpq $(NTP_TARGET_DIR)/usr/sbin
	cp -aL ntp-wait $(NTP_TARGET_DIR)/usr/sbin
	cp -aL ntp.init $(NTP_TARGET_DIR)/etc/init.d/ntp
	cp -aL ntp.default $(NTP_TARGET_DIR)/etc/default/ntp
	cp -aL ntp.conf $(NTP_TARGET_DIR)/etc/ntp.conf
	cp -aL ntp.daily $(NTP_TARGET_DIR)/etc/cron.daily/ntp
	cp -aL ntp.weekly $(NTP_TARGET_DIR)/etc/cron.weekly/ntp
	cp -aL ntp.ifup $(NTP_TARGET_DIR)/etc/network/if-up.d/ntp
	cp -a $(NTP_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(NTP_DIR)/.build

build: $(NTP_DIR)/.build
                                                                                         
clean:
	make -C $(NTP_DIR) clean
	rm -rf $(NTP_TARGET_DIR)
	-rm $(NTP_DIR)/.build
	-rm $(NTP_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(NTP_DIR) 
