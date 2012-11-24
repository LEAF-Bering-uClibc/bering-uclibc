# makefile for quagga

QUAGGA_DIR:=quagga-0.99.21
QUAGGA_TARGET_DIR:=$(BT_BUILD_DIR)/quagga

$(QUAGGA_DIR)/.source:
	zcat $(QUAGGA_SOURCE) | tar -xvf -
	cat $(QUAGGA_PATCH1) | patch -p1 -d $(QUAGGA_DIR)
	touch $(QUAGGA_DIR)/.source

source: $(QUAGGA_DIR)/.source

$(QUAGGA_DIR)/.configured: $(QUAGGA_DIR)/.source
	(cd $(QUAGGA_DIR) ; ./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--sysconfdir=/etc/zebra \
	--disable-doc \
	--disable-ospfapi \
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
	make $(MAKEOPTS) -C $(QUAGGA_DIR)
	make $(MAKEOPTS) DESTDIR=$(QUAGGA_TARGET_DIR) -C $(QUAGGA_DIR) install
	-$(BT_STRIP) $(B_STRIP_BINOPTS) $(QUAGGA_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(B_STRIP_LIBOPTS) $(QUAGGA_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(QUAGGA_TARGET_DIR)/usr/lib/*.la
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
	cp -a $(QUAGGA_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(QUAGGA_DIR)/.build

build: $(QUAGGA_DIR)/.build

clean:
	-make -C $(QUAGGA_DIR) clean
	-rm -rf $(QUAGGA_TARGET_DIR)
	-rm -rf $(QUAGGA_DIR)/.build
	-rm -rf $(QUAGGA_DIR)/.configured

srcclean: clean
	-rm -rf $(QUAGGA_DIR)
