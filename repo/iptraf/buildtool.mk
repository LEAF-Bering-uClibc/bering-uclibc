# makefile for iptraf

IPTRAF_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(IPTRAF_SOURCE) 2>/dev/null )

IPTRAF_TARGET_DIR:=$(BT_BUILD_DIR)/iptraf

ENVVAR=WORKDIR=/var/lib/iptraf \
	LOGDIR=/var/log/iptraf \
	TARGET=/usr/sbin \
	CC=$(TARGET_CC) \
	AR=$(TARGET_AR) \
	RANLIB=$(TARGET_RANLIB) \
	CFLAGS="$(CFLAGS) -std=gnu99"  LDOPTS="$(LDFLAGS)"

$(IPTRAF_DIR)/.source:
	zcat $(IPTRAF_SOURCE) | tar -xvf -
	touch $(IPTRAF_DIR)/.source

source: $(IPTRAF_DIR)/.source

$(IPTRAF_DIR)/.configured: $(IPTRAF_DIR)/.source
	(cd $(IPTRAF_DIR) ; ./configure \
	--prefix=/usr \
	--with-ncurses \
	--host=$(GNU_TARGET_NAME))
	touch $(IPTRAF_DIR)/.configured

$(IPTRAF_DIR)/.build: $(IPTRAF_DIR)/.configured
	mkdir -p $(IPTRAF_TARGET_DIR)
	mkdir -p $(IPTRAF_TARGET_DIR)/var/log/iptraf
	mkdir -p $(IPTRAF_TARGET_DIR)/var/run/iptraf
	mkdir -p $(IPTRAF_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(IPTRAF_DIR) $(ENVVAR)
	cp -a $(IPTRAF_DIR)/iptraf-ng $(IPTRAF_TARGET_DIR)/usr/sbin/
	cp -a $(IPTRAF_DIR)/rvnamed-ng $(IPTRAF_TARGET_DIR)/usr/sbin/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPTRAF_TARGET_DIR)/usr/sbin/*
	cp -a $(IPTRAF_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IPTRAF_DIR)/.build

build: $(IPTRAF_DIR)/.build

clean:
	make -C $(IPTRAF_DIR) clean
	rm -rf $(IPTRAF_TARGET_DIR)
	rm -rf $(IPTRAF_DIR)/.build
	rm -rf $(IPTRAF_DIR)/.configured

srcclean: clean
	rm -rf $(IPTRAF_DIR)
