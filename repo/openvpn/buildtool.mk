#
#
#
include $(MASTERMAKEFILE)

OPENVPN_DIR:=openvpn-2.3.0
OPENVPN_TARGET_DIR=$(BT_BUILD_DIR)/openvpn

$(OPENVPN_DIR)/.source:
	zcat $(OPENVPN_SOURCE) | tar -xvf -
	perl -i -p -e 's,group nobody,group nogroup,' $(OPENVPN_DIR)/sample/sample-config-files/server.conf
	perl -i -p -e 's,group nobody,group nogroup,' $(OPENVPN_DIR)/sample/sample-config-files/client.conf
	perl -i -p -e 's,status openvpn-status.log,status /var/log/openvpn-status.log,' $(OPENVPN_DIR)/sample/sample-config-files/server.conf
	perl -i -p -e 's,ifconfig-pool-persist ipp.txt,ifconfig-pool-persist /var/lib/openvpn-ipp.txt,' $(OPENVPN_DIR)/sample/sample-config-files/server.conf
	touch $(OPENVPN_DIR)/.source


$(OPENVPN_DIR)/.build: $(OPENVPN_DIR)/.source
	mkdir -p $(OPENVPN_TARGET_DIR)/etc/openvpn
	mkdir -p $(OPENVPN_TARGET_DIR)/etc/init.d
	mkdir -p $(OPENVPN_TARGET_DIR)/etc/default
	mkdir -p $(OPENVPN_TARGET_DIR)/etc/network/if-up.d
	mkdir -p $(OPENVPN_TARGET_DIR)/etc/network/if-down.d
	mkdir -p $(OPENVPN_TARGET_DIR)/usr/sbin

	# Build a version without lzo support
	(cd $(OPENVPN_DIR); \
		rm -rf config.cache; \
		./configure \
			--with-ssl-headers=$(BT_STAGING_DIR)/usr/include \
			--with-ssl-lib=$(BT_STAGING_DIR)/usr/lib \
			--disable-dependency-tracking \
			--enable-ssl \
			--enable-iproute2 \
			--with-iproute-path=/sbin/ip \
			--disable-lzo \
			--enable-pthread \
			--prefix=/usr \
			--disable-socks \
			--disable-http \
			--disable-debug \
			--disable-plugin-auth-pam \
			--enable-small )
#			--libdir=$(BT_STAGING_DIR)/lib );
#			--includedir=$(BT_STAGING_DIR)/include \

		make $(MAKEOPTS) -C $(OPENVPN_DIR)
		make DESTDIR=$(OPENVPN_TARGET_DIR) -C $(OPENVPN_DIR) install
		cp $(OPENVPN_DIR)/sample/sample-config-files/server.conf  $(OPENVPN_TARGET_DIR)/etc/openvpn/
		cp $(OPENVPN_DIR)/sample/sample-config-files/client.conf  $(OPENVPN_TARGET_DIR)/etc/openvpn/
		cp -aL openvpn.init $(OPENVPN_TARGET_DIR)/etc/init.d/openvpn
		cp -aL openvpn.default $(OPENVPN_TARGET_DIR)/etc/default/openvpn
		cp -aL openvpn.ifup $(OPENVPN_TARGET_DIR)/etc/network/if-up.d/openvpn
		cp -aL openvpn.ifdown $(OPENVPN_TARGET_DIR)/etc/network/if-down.d/openvpn

		# make sure lzo is disabled in the sample config
		perl -i -p -e 's,^comp-lzo,;comp-lzo,' $(OPENVPN_TARGET_DIR)/etc/openvpn/server.conf
		perl -i -p -e 's,^comp-lzo,;comp-lzo,' $(OPENVPN_TARGET_DIR)/etc/openvpn/client.conf

		# clean up for the next round
		make -C $(OPENVPN_DIR) clean

		# Build a version with lzo support
		(cd $(OPENVPN_DIR); \
			rm -rf config.cache; \
			./configure \
				--host=$(GNU_TARGET_NAME) \
				--build=$(GNU_BUILD_NAME) \
				--with-ssl-headers=$(BT_STAGING_DIR)/usr/include \
				--with-ssl-lib=$(BT_STAGING_DIR)/usr/lib \
				--disable-dependency-tracking \
				--enable-ssl \
				--enable-iproute2 \
				--with-iproute-path=/sbin/ip \
				--with-lzo-headers=$(BT_STAGING_DIR)/usr/include \
				--with-lzo-lib=$(BT_STAGING_DIR)/usr/lib \
				--enable-pthread \
				--prefix=/usr \
				--disable-socks \
				--disable-http \
				--disable-plugin-auth-pam \
				--disable-debug \
				--enable-small \
				);

		make $(MAKEOPTS) -C $(OPENVPN_DIR)

		cp $(OPENVPN_DIR)/sample/sample-config-files/server.conf  $(OPENVPN_TARGET_DIR)/etc/openvpn/server.lzo.conf
		cp $(OPENVPN_DIR)/sample/sample-config-files/client.conf  $(OPENVPN_TARGET_DIR)/etc/openvpn/client.lzo.conf
		mv $(OPENVPN_DIR)/src/openvpn/openvpn $(OPENVPN_TARGET_DIR)/usr/sbin/openvpn_lzo
		make -C $(OPENVPN_DIR) clean

		-rm -rf $(OPENVPN_TARGET_DIR)/usr/share
		-$(BT_STRIP) $(BT_STRIP_BINOPS) $(OPENVPN_TARGET_DIR)/usr/sbin/*
		cp -a $(OPENVPN_TARGET_DIR)/* $(BT_STAGING_DIR)

		touch $(OPENVPN_DIR)/.build

source: $(OPENVPN_DIR)/.source

build: $(OPENVPN_DIR)/.build

clean:
	-rm $(OPENVPN_DIR)/.build
	make -C $(OPENVPN_DIR) clean
	rm -rf $(OPENVPN_TARGET_DIR)

srcclean:
	rm -rf $(OPENVPN_DIR)
	rm -rf $(BT_STAGING_DIR)/etc/openvpn
	rm -f  $(BT_STAGING_DIR)/etc/init.d/openvpn
	rm -f  $(BT_STAGING_DIR)/etc/default/openvpn
	rm -f  $(BT_STAGING_DIR)/etc/network/if-up.d/openvpn
	rm -f  $(BT_STAGING_DIR)/etc/network/if-down.d/openvpn
	rm -f $(BT_STAGING_DIR)/usr/sbin/openvpn
	rm -f $(BT_STAGING_DIR)/usr/sbin/openvpn_lzo
