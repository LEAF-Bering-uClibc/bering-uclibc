# makefile for dnsmasq
include $(MASTERMAKEFILE)

DNSMASQ_DIR:=dnsmasq-2.59
DNSMASQ_TARGET_DIR:=$(BT_BUILD_DIR)/dnsmasq

$(DNSMASQ_DIR)/.source:
	zcat $(DNSMASQ_SOURCE) | tar -xvf -
	touch $(DNSMASQ_DIR)/.source

source: $(DNSMASQ_DIR)/.source

$(DNSMASQ_DIR)/.configured: $(DNSMASQ_DIR)/.source
	touch $(DNSMASQ_DIR)/.configured

$(DNSMASQ_DIR)/.build: $(DNSMASQ_DIR)/.configured
	mkdir -p $(DNSMASQ_TARGET_DIR)
	mkdir -p $(DNSMASQ_TARGET_DIR)/usr/sbin
	mkdir -p $(DNSMASQ_TARGET_DIR)/etc/init.d
	# Disable the internal tftpd with -DNO_TFTP
	make -C $(DNSMASQ_DIR) DESTDIR=$(DNSMASQ_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS) -DNO_TFTP" all
	# Adjust the dnsmasq.conf to LEAF standard
	perl -i -p -e 's,\#dhcp-range=192.168.0.50\,192.168.0.150\,12h,\#dhcp-range=192.168.1.1\,192.168.1.199\,12h,g' $(DNSMASQ_DIR)/dnsmasq.conf.example
	perl -i -p -e 's,\#domain=thekelleys.org.uk,domain=private.network,g' $(DNSMASQ_DIR)/dnsmasq.conf.example
	perl -i -p -e 's,\#local=/localnet/,local=/private.network/,g' $(DNSMASQ_DIR)/dnsmasq.conf.example
	cp -aL dnsmasq.init $(DNSMASQ_TARGET_DIR)/etc/init.d/dnsmasq
	cp -a $(DNSMASQ_DIR)/src/dnsmasq $(DNSMASQ_TARGET_DIR)/usr/sbin
	cp -a $(DNSMASQ_DIR)/dnsmasq.conf.example $(DNSMASQ_TARGET_DIR)/etc/dnsmasq.conf
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DNSMASQ_TARGET_DIR)/usr/sbin/dnsmasq
	cp -a $(DNSMASQ_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DNSMASQ_DIR)/.build

build: $(DNSMASQ_DIR)/.build

clean:
	make -C $(DNSMASQ_DIR) clean
	rm -rf $(DNSMASQ_TARGET_DIR)
	rm -rf $(DNSMASQ_DIR)/.build
	rm -rf $(DNSMASQ_DIR)/.configured

srcclean: clean
	rm -rf $(DNSMASQ_DIR) 
