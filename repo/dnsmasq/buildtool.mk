############################################
# makefile for dnsmasq
###########################################

DNSMASQ_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(DNSMASQ_SOURCE) 2>/dev/null)
DNSMASQ_TARGET_DIR:=$(BT_BUILD_DIR)/dnsmasq

$(DNSMASQ_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(DNSMASQ_SOURCE)
	touch $(DNSMASQ_DIR)/.source

source: $(DNSMASQ_DIR)/.source

$(DNSMASQ_DIR)/.build: $(DNSMASQ_DIR)/.source
	mkdir -p $(DNSMASQ_TARGET_DIR)
	mkdir -p $(DNSMASQ_TARGET_DIR)/usr/sbin
	mkdir -p $(DNSMASQ_TARGET_DIR)/etc/init.d

# Disable the internal tftpd with -DNO_TFTP
	make $(MAKEOPTS) -C $(DNSMASQ_DIR) DESTDIR=$(DNSMASQ_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS) -Wall -w -DNO_TFTP" LDFLAGS="$(LDFLAGS)" all
# Adjust the dnsmasq.conf to LEAF standard
	perl -i -p -e 's,\#dhcp-range=192.168.0.50\,192.168.0.150\,12h,\#dhcp-range=192.168.1.1\,192.168.1.199\,12h,g' $(DNSMASQ_DIR)/dnsmasq.conf.example
	perl -i -p -e 's,\#domain=thekelleys.org.uk,domain=private.network,g' $(DNSMASQ_DIR)/dnsmasq.conf.example
	perl -i -p -e 's,\#local=/localnet/,local=/private.network/,g' $(DNSMASQ_DIR)/dnsmasq.conf.example
	cp -aL dnsmasq.init $(DNSMASQ_TARGET_DIR)/etc/init.d/dnsmasq
	cp -a $(DNSMASQ_DIR)/src/dnsmasq $(DNSMASQ_TARGET_DIR)/usr/sbin
	cp -a $(DNSMASQ_DIR)/dnsmasq.conf.example $(DNSMASQ_TARGET_DIR)/etc/dnsmasq.conf
	cp -a $(DNSMASQ_DIR)/trust-anchors.conf $(DNSMASQ_TARGET_DIR)/etc/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DNSMASQ_TARGET_DIR)/usr/sbin/*
	cp -a $(DNSMASQ_TARGET_DIR)/* $(BT_STAGING_DIR)

# build dnsmasq with dnssec support
	make -C $(DNSMASQ_DIR) clean
	make $(MAKEOPTS) -C $(DNSMASQ_DIR) DESTDIR=$(DNSMASQ_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS) -Wall -w -DHAVE_DNSSEC -DNO_TFTP" LDFLAGS="$(LDFLAGS) -lnettle -lgmp -lhogweed" all
	cp -a $(DNSMASQ_DIR)/src/dnsmasq $(DNSMASQ_TARGET_DIR)/usr/sbin/dnsmasqsec
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DNSMASQ_TARGET_DIR)/usr/sbin/dnsmasqsec
	cp -a $(DNSMASQ_TARGET_DIR)/usr/sbin/dnsmasqsec $(BT_STAGING_DIR)/usr/sbin
	touch $(DNSMASQ_DIR)/.build

build: $(DNSMASQ_DIR)/.build

clean:
	make -C $(DNSMASQ_DIR) clean
	rm -rf $(DNSMASQ_TARGET_DIR)
	rm -rf $(DNSMASQ_DIR)/.build
	rm -rf $(DNSMASQ_DIR)/.configured

srcclean: clean
	rm -rf $(DNSMASQ_DIR)
