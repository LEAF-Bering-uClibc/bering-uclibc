# makefile for quagga
include $(MASTERMAKEFILE)

QUAGGA_DIR:=quagga-0.99.20
QUAGGA_TARGET_DIR:=$(BT_BUILD_DIR)/quagga

$(QUAGGA_DIR)/.source:
	zcat $(QUAGGA_SOURCE) | tar -xvf -
	touch $(QUAGGA_DIR)/.source

source: $(QUAGGA_DIR)/.source
                        
$(QUAGGA_DIR)/.configured: $(QUAGGA_DIR)/.source
	(cd $(QUAGGA_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS) -g -Wall" ./configure --prefix=/usr \
	--sysconfdir=/etc/zebra \
	--enable-isisd \
	--enable-ipv6 \
	--enable-netlink \
	--enable-rtadv \
	--enable-user=root \
	--enable-group=root \
	--enable-multipath=0 \
	--localstatedir=/var/run \
	$(NULL))
	touch $(QUAGGA_DIR)/.configured
                                                                 
$(QUAGGA_DIR)/.build: $(QUAGGA_DIR)/.configured
	mkdir -p $(QUAGGA_TARGET_DIR)
	mkdir -p $(QUAGGA_TARGET_DIR)/etc/zebra
	mkdir -p $(QUAGGA_TARGET_DIR)/etc/init.d
	mkdir -p $(QUAGGA_TARGET_DIR)/usr/sbin	
	mkdir -p $(QUAGGA_TARGET_DIR)/lib
	make -C $(QUAGGA_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/zebra/.libs/zebra
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/ripd/.libs/ripd
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/ripngd/.libs/ripngd
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/ospfd/.libs/ospfd
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/ospf6d/.libs/ospf6d
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/bgpd/.libs/bgpd
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(QUAGGA_DIR)/isisd/.libs/isisd		
	-$(BT_STRIP) --strip-unneeded $(QUAGGA_DIR)/lib/.libs/libzebra.so.0.0.0
	-$(BT_STRIP) --strip-unneeded $(QUAGGA_DIR)/ospfd/.libs/libospf.so.0.0.0

	cp -aL bgpd.init $(QUAGGA_TARGET_DIR)/etc/init.d/bgpd
	cp -aL bgpd.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -aL isisd.init $(QUAGGA_TARGET_DIR)/etc/init.d/isisd
	cp -aL isisd.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -aL ospfd.init $(QUAGGA_TARGET_DIR)/etc/init.d/ospfd
	cp -aL ospfd.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -aL ospf6d.init $(QUAGGA_TARGET_DIR)/etc/init.d/ospf6d
	cp -aL ospf6d.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -aL ripd.init $(QUAGGA_TARGET_DIR)/etc/init.d/ripd
	cp -aL ripd.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -aL ripngd.init $(QUAGGA_TARGET_DIR)/etc/init.d/ripngd
	cp -aL ripngd.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -aL zebra.init $(QUAGGA_TARGET_DIR)/etc/init.d/zebra
	cp -aL zebra.conf $(QUAGGA_TARGET_DIR)/etc/zebra
	cp -a $(QUAGGA_DIR)/zebra/.libs/zebra $(QUAGGA_TARGET_DIR)/usr/sbin
	cp -a $(QUAGGA_DIR)/ripd/.libs/ripd $(QUAGGA_TARGET_DIR)/usr/sbin	
	cp -a $(QUAGGA_DIR)/ripngd/.libs/ripngd $(QUAGGA_TARGET_DIR)/usr/sbin	
	cp -a $(QUAGGA_DIR)/ospfd/.libs/ospfd $(QUAGGA_TARGET_DIR)/usr/sbin
	cp -a $(QUAGGA_DIR)/ospf6d/.libs/ospf6d $(QUAGGA_TARGET_DIR)/usr/sbin
	cp -a $(QUAGGA_DIR)/bgpd/.libs/bgpd $(QUAGGA_TARGET_DIR)/usr/sbin
	cp -a $(QUAGGA_DIR)/isisd/.libs/isisd $(QUAGGA_TARGET_DIR)/usr/sbin	
	cp -a $(QUAGGA_DIR)/lib/.libs/libzebra.so.0.0.0 $(QUAGGA_TARGET_DIR)/lib
	cp -a $(QUAGGA_DIR)/ospfd/.libs/libospf.so.0.0.0 $(QUAGGA_TARGET_DIR)/lib	
	cp -a $(QUAGGA_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(QUAGGA_DIR)/.build

build: $(QUAGGA_DIR)/.build
                                                                                         
clean:
	make -C $(QUAGGA_DIR) clean
	rm -rf $(QUAGGA_TARGET_DIR)
	rm -rf $(QUAGGA_DIR)/.build
	rm -rf $(QUAGGA_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(QUAGGA_DIR) 
	rm -rf $(QUAGGA_DIR)/.source
