###########################################
# makefile for squid
##########################################

SQUID_DIR:=squid-3.4.4
SQUID_TARGET_DIR:=$(BT_BUILD_DIR)/squid
export HOSTCXX=g++

$(SQUID_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SQUID_SOURCE)
	cat $(SQUID_CERTIFICATE_PATCH) | patch -d $(SQUID_DIR) -p1
	cp config.test $(SQUID_DIR)/helpers/external_acl/session/
	touch $(SQUID_DIR)/.source

source: $(SQUID_DIR)/.source

$(SQUID_DIR)/.configured: $(SQUID_DIR)/.source
	(cd $(SQUID_DIR) ; rm aclocal.m4 Makefile.in; \
	libtoolize -i -f && autoreconf -i -f && \
	./configure \
	--sysconfdir=/etc/squid --prefix= \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--enable-internal-dns \
	--exec-prefix=/usr --libexecdir=/usr/bin \
	--enable-snmp \
	--datadir=/etc/squid \
	--disable-wccp --disable-wccpv2 \
	--enable-poll --enable-delay-pools \
	--enable-default-err-language=English \
	--enable-err-languages="English" \
	--disable-strict-error-checking \
	--disable-external-acl-helpers \
	--disable-auth \
	--enable-removal-policies="lru,heap" \
	--enable-digest-auth-helpers="password" \
	--enable-epoll \
	--disable-mit \
	--disable-heimdal \
	--enable-delay-pools \
	--enable-arp-acl \
	--enable-ssl \
	--enable-linux-netfilter \
	--disable-ident-lookups \
	--enable-useragent-log \
	--enable-cache-digests \
	--enable-referer-log \
	--enable-async-io \
	--enable-truncate \
	--enable-arp-acl \
	--enable-htcp \
	--enable-carp \
	--enable-poll --with-maxfd=4096 \
	--enable-follow-x-forwarded-for \
	--without-krb5-config \
	--without-large-files )

	touch $(SQUID_DIR)/.configured

$(SQUID_DIR)/.build: $(SQUID_DIR)/.configured
	mkdir -p $(SQUID_TARGET_DIR)
	mkdir -p $(SQUID_TARGET_DIR)/etc/init.d
	mkdir -p $(SQUID_TARGET_DIR)/etc/cron.daily
	mkdir -p $(SQUID_TARGET_DIR)/etc/squid
	mkdir -p $(SQUID_TARGET_DIR)/etc/squid/errors/en
	mkdir -p $(SQUID_TARGET_DIR)/etc/squid/icons/silk
	mkdir -p $(SQUID_TARGET_DIR)/usr/sbin
	mkdir -p $(SQUID_TARGET_DIR)/usr/bin
	mkdir -p $(SQUID_TARGET_DIR)/usr/lib/cgi-bin
#       breaks patch
#	make CFLAGS="$(BT_COPT_FLAGS)" -C $(SQUID_DIR) all
	make $(MAKEOPTS) -C $(SQUID_DIR) all
	chmod 644 $(SQUID_DIR)/icons/silk/*
	cp -aL squid.init $(SQUID_TARGET_DIR)/etc/init.d/squid
	cp -aL squid.conf $(SQUID_TARGET_DIR)/etc/squid
	cp -aL ok_domains $(SQUID_TARGET_DIR)/etc/squid
	cp -a $(SQUID_DIR)/src/mib.txt $(SQUID_TARGET_DIR)/etc/squid
	cp -aL squid.daily $(SQUID_TARGET_DIR)/etc/cron.daily/squid
	cp -a $(SQUID_DIR)/src/mime.conf.default $(SQUID_TARGET_DIR)/etc/squid/mime.conf
	cp -a $(SQUID_DIR)/errors/en/* $(SQUID_TARGET_DIR)/etc/squid/errors/en
	cp -a $(SQUID_DIR)/errors/errorpage.css $(SQUID_TARGET_DIR)/etc/squid/
	cp -a $(SQUID_DIR)/icons/silk/*.png $(SQUID_TARGET_DIR)/etc/squid/icons/silk
	cp -a $(SQUID_DIR)/icons/SN.png $(SQUID_TARGET_DIR)/etc/squid/icons
	cp -a $(SQUID_DIR)/src/squid $(SQUID_TARGET_DIR)/usr/sbin
	cp -a $(SQUID_DIR)/tools/squidclient $(SQUID_TARGET_DIR)/usr/bin
#	cp -a $(SQUID_DIR)/src/dnsserver $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/src/unlinkd $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/helpers/log_daemon/file/log_file_daemon $(SQUID_TARGET_DIR)/usr/bin
	cp -a $(SQUID_DIR)/tools/cachemgr.cgi $(SQUID_TARGET_DIR)/usr/lib/cgi-bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SQUID_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SQUID_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SQUID_TARGET_DIR)/usr/lib/cgi-bin/*
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
