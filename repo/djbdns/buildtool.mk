# makefile for DJDBNS
include $(MASTERMAKEFILE)

DJBDNS_DIR:=djbdns-1.05
DJBDNS_TARGET_DIR:=$(BT_BUILD_DIR)/djbdns

$(DJBDNS_DIR)/.source:
	zcat $(DJBDNS_SOURCE) | tar -xvf -
	bzcat $(DJBDNS_PATCH1) | patch -d $(DJBDNS_DIR) -p1
	perl -i -p -e 's,-O2,$(CFLAGS),g' $(DJBDNS_DIR)/conf-cc
	perl -i -p -e 's,gcc\s+,$(TARGET_CC) ,g' $(DJBDNS_DIR)/conf-cc
	perl -i -p -e 's;gcc\s*-s;$(TARGET_CC) -s $(LDFLAGS);g' $(DJBDNS_DIR)/conf-ld
	perl -i -p -e 's,/usr/local,/usr,g' $(DJBDNS_DIR)/conf-home
	touch $(DJBDNS_DIR)/.source

source: $(DJBDNS_DIR)/.source

$(DJBDNS_DIR)/.build: $(DJBDNS_DIR)/.source
	cd $(DJBDNS_DIR)
	mkdir -p $(DJBDNS_TARGET_DIR)/usr/bin
	mkdir -p $(DJBDNS_TARGET_DIR)/usr/sbin
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/dnscache/env
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/dnscache/log
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/init.d

	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/dnscache/env
	mkdir -p $(BT_STAGING_DIR)/etc/dnscache/log
	mkdir -p $(BT_STAGING_DIR)/etc/init.d

	mkdir -p  $(DJBDNS_TARGET_DIR)/etc/tinydns-public/env
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/tinydns-private/env
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/tinydns-private/log
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/tinydns-private/root
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/tinydns-public/log
	mkdir -p $(DJBDNS_TARGET_DIR)/etc/tinydns-public/root

	make $(MAKEOPTS) -C $(DJBDNS_DIR)

	cp $(DJBDNS_DIR)/dnscache-conf $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/tinydns-conf $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/walldns-conf $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/rbldns-conf $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/pickdns-conf $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/axfrdns-conf $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnscache $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/tinydns $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/walldns $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/rbldns $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/pickdns $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/axfrdns $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/tinydns-get $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/tinydns-data $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/tinydns-edit $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/rbldns-data $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/pickdns-data $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/axfr-get $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsip $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsip6 $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsipq $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsip6q $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsname $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnstxt $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsmx $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsfilter $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/random-ip $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsqr $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsq $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnstrace $(DJBDNS_TARGET_DIR)/usr/bin/

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DJBDNS_TARGET_DIR)/usr/bin/*

	cp $(DJBDNS_DIR)/dnstracesort $(DJBDNS_TARGET_DIR)/usr/bin/
	cp $(DJBDNS_DIR)/dnsroots.global $(DJBDNS_TARGET_DIR)/etc/

	# don't keep empty files in CVS
	touch $(DJBDNS_TARGET_DIR)/etc/dnscache/env/DNS1
	cp -aL dnscache.env.FORWARDONLY $(DJBDNS_TARGET_DIR)/etc/dnscache/env/FORWARDONLY
	cp -aL dnscache.env.IP $(DJBDNS_TARGET_DIR)/etc/dnscache/env/IP
	cp -aL dnscache.env.IPQUERY $(DJBDNS_TARGET_DIR)/etc/dnscache/env/IPQUERY
	cp -aL dnscache.env.IPSEND $(DJBDNS_TARGET_DIR)/etc/dnscache/env/IPSEND
	cp -aL dnscache.env.QUERYFWD $(DJBDNS_TARGET_DIR)/etc/dnscache/env/QUERYFWD
	cp -aL dnscache.env.QUERYLOG $(DJBDNS_TARGET_DIR)/etc/dnscache/env/QUERYLOG
	cp -aL dnscache.env.ROOT $(DJBDNS_TARGET_DIR)/etc/dnscache/env/ROOT
	cp -aL dnscache.env.CACHESIZE $(DJBDNS_TARGET_DIR)/etc/dnscache/env/CACHESIZE
	cp -aL dnscache.env.DATALIMIT $(DJBDNS_TARGET_DIR)/etc/dnscache/env/DATALIMIT

	cp -aL dnscache.seed $(DJBDNS_TARGET_DIR)/etc/dnscache/seed
	cp -aL dnscache.run $(DJBDNS_TARGET_DIR)/etc/dnscache/run
	cp -aL dnscache.log.run $(DJBDNS_TARGET_DIR)/etc/dnscache/log/run
	cp -aL dnscache $(DJBDNS_TARGET_DIR)/etc/init.d/

	cp -aL tinydns.private.log.run $(DJBDNS_TARGET_DIR)/etc/tinydns-private/log/run
	cp -aL tinydns.private.env.ROOT $(DJBDNS_TARGET_DIR)/etc/tinydns-private/env/ROOT
	cp -aL tinydns.private.env.IP $(DJBDNS_TARGET_DIR)/etc/tinydns-private/env/IP
	cp -aL tinydns.private.env.DOMAINS $(DJBDNS_TARGET_DIR)/etc/tinydns-private/env/DOMAINS
	cp -aL tinydns.private.env.DNSTYPE $(DJBDNS_TARGET_DIR)/etc/tinydns-private/env/DNSTYPE
	cp -aL tinydns.private.env.QUERYLOG $(DJBDNS_TARGET_DIR)/etc/tinydns-private/env/QUERYLOG
	cp -aL tinydns.private.run $(DJBDNS_TARGET_DIR)/etc/tinydns-private/run

	cp -aL tinydns.public.log.run $(DJBDNS_TARGET_DIR)/etc/tinydns-public/log/run
	cp -aL tinydns.public.env.ROOT $(DJBDNS_TARGET_DIR)/etc/tinydns-public/env/ROOT
	cp -aL tinydns.public.env.QUERYLOG $(DJBDNS_TARGET_DIR)/etc/tinydns-public/env/QUERYLOG
	cp -aL tinydns.public.run $(DJBDNS_TARGET_DIR)/etc/tinydns-public/run

	cp -aL tinydns $(DJBDNS_TARGET_DIR)/etc/init.d/tinydns
	# don't keep empty files in CVS
	touch $(DJBDNS_TARGET_DIR)/etc/tinydns-public/env/IP
	touch $(DJBDNS_TARGET_DIR)/etc/tinydns-private/root/data
	touch $(DJBDNS_TARGET_DIR)/etc/tinydns-public/log/status
	touch $(DJBDNS_TARGET_DIR)/etc/tinydns-private/log/status
	touch $(DJBDNS_TARGET_DIR)/etc/tinydns-public/root/data

	cp -a $(DJBDNS_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DJBDNS_DIR)/.build

build: $(DJBDNS_DIR)/.build

clean:
	-make -C $(DJBDNS_DIR) clean
	rm -rf $(DJBDNS_TARGET_DIR)
	-rm $(DJBDNS_DIR)/.build

srcclean: clean
	rm -rf $(DJBDNS_DIR)
	-rm $(DJBDNS_DIR)/.source


