# makefile for dropbear
include $(MASTERMAKEFILE)

DROPBEAR_DIR=$(shell echo $(DROPBEAR_SOURCE) | sed 's/\.\(tar\.\|\t\)\(gz\|bz2\)//')
DROPBEAR_TARGET_DIR:=$(BT_BUILD_DIR)/dropbear

$(DROPBEAR_DIR)/.source:
	zcat $(DROPBEAR_SOURCE) | tar -xvf -
	touch $(DROPBEAR_DIR)/.source

source: $(DROPBEAR_DIR)/.source

$(DROPBEAR_DIR)/.configured: $(DROPBEAR_DIR)/.source
	(cd $(DROPBEAR_DIR) ; \
	./configure --prefix=/usr --disable-zlib --disable-lastlog --enable-bundled-libtom --host=$(GNU_TARGET_NAME))
	cp options.h $(DROPBEAR_DIR)
	touch $(DROPBEAR_DIR)/.configured

$(DROPBEAR_DIR)/.build: $(DROPBEAR_DIR)/.configured
	mkdir -p $(DROPBEAR_TARGET_DIR)
	mkdir -p $(DROPBEAR_TARGET_DIR)/etc/init.d
	mkdir -p $(DROPBEAR_TARGET_DIR)/etc/default
	mkdir -p $(DROPBEAR_TARGET_DIR)/usr/bin
	mkdir -p $(DROPBEAR_TARGET_DIR)/usr/sbin
	$(MAKE) $(MAKEOPTS) PROGRAMS="dropbear dropbearkey scp" MULTI=1 STATIC=0 SCPPROGRESS=0 -C $(DROPBEAR_DIR)
	cp -a $(DROPBEAR_DIR)/dropbearmulti $(DROPBEAR_TARGET_DIR)/usr/sbin
	cp -aL dropbear.init $(DROPBEAR_TARGET_DIR)/etc/init.d/dropbear
	cp -aL dropbear.conf $(DROPBEAR_TARGET_DIR)/etc/default/dropbear

	$(MAKE) -C $(DROPBEAR_DIR) clean

	$(MAKE) $(MAKEOPTS) PROGRAMS="dbclient" MULTI=0 STATIC=0 -C $(DROPBEAR_DIR)
	cp -a $(DROPBEAR_DIR)/dbclient $(DROPBEAR_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DROPBEAR_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DROPBEAR_TARGET_DIR)/usr/sbin/*
	cp -a $(DROPBEAR_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DROPBEAR_DIR)/.build

build: $(DROPBEAR_DIR)/.build

clean:
	make -C $(DROPBEAR_DIR) clean
	rm -rf $(DROPBEAR_TARGET_DIR)
	rm -f $(DROPBEAR_DIR)/.build
	rm -f $(DROPBEAR_DIR)/.configured

srcclean: clean
	rm -rf $(DROPBEAR_DIR)
