# makefile for iptraf
include $(MASTERMAKEFILE)

IPTRAF_DIR:=iptraf-2.7.0
IPTRAF_TARGET_DIR:=$(BT_BUILD_DIR)/iptraf
ENVVAR=WORKDIR=/var/lib/iptraf \
	LOGDIR=/var/log/iptraf \
	TARGET=/usr/sbin \
	CC=$(TARGET_CC) \
	AR=$(TARGET_AR) \
	RANLIB=$(TARGET_RANLIB) \
	CFLAGS="$(CFLAGS)" LDOPTS="$(LDFLAGS)"


$(IPTRAF_DIR)/.source:
	zcat $(IPTRAF_SOURCE) | tar -xvf -
	zcat $(IPTRAF_PATCH1) | patch -d $(IPTRAF_DIR) -p1
	zcat $(IPTRAF_PATCH2) | patch -d $(IPTRAF_DIR) -p1
	cat $(IPTRAF_PATCH3) | patch -d $(IPTRAF_DIR)/support -p0
	touch $(IPTRAF_DIR)/.source

source: $(IPTRAF_DIR)/.source

$(IPTRAF_DIR)/.configured: $(IPTRAF_DIR)/.source
	perl -i -p -e 's,INCLUDEDIR\s*=\s*-I/usr/include/ncurses -I../support,INCLUDEDIR = -I$(BT_STAGING_DIR)/usr/include -I../support,ig' $(IPTRAF_DIR)/src/Makefile
	perl -i -p -e 's,INCLUDEDIR\s*=\s*-I/usr/include/ncurses,INCLUDEDIR = -I$(BT_STAGING_DIR)/usr/include,ig' $(IPTRAF_DIR)/support/Makefile
	touch $(IPTRAF_DIR)/.configured

$(IPTRAF_DIR)/.build: $(IPTRAF_DIR)/.configured
	mkdir -p $(IPTRAF_TARGET_DIR)
	mkdir -p $(IPTRAF_TARGET_DIR)/var/log/iptraf
	mkdir -p $(IPTRAF_TARGET_DIR)/var/run/iptraf
	mkdir -p $(IPTRAF_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(IPTRAF_DIR)/src $(ENVVAR)
	cp -a $(IPTRAF_DIR)/src/iptraf $(IPTRAF_TARGET_DIR)/usr/sbin
	cp -a $(IPTRAF_DIR)/src/rvnamed $(IPTRAF_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPTRAF_TARGET_DIR)/usr/sbin/*
	cp -a $(IPTRAF_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IPTRAF_DIR)/.build

build: $(IPTRAF_DIR)/.build

clean:
	make -C $(IPTRAF_DIR)/src clean
	make -C $(IPTRAF_DIR)/support clean
	rm -rf $(IPTRAF_TARGET_DIR)
	rm -rf $(IPTRAF_DIR)/.build
	rm -rf $(IPTRAF_DIR)/.configured

srcclean: clean
	rm -rf $(IPTRAF_DIR)
