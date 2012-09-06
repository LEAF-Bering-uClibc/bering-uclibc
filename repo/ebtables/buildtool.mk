# makefile for ebtables
include $(MASTERMAKEFILE)

EBTABLES_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(EBTABLES_SOURCE) 2>/dev/null )
EBTABLES_TARGET_DIR:=$(BT_BUILD_DIR)/ebtables

$(EBTABLES_DIR)/.source:
	tar xvzf $(EBTABLES_SOURCE)
#	zcat $(EBTABLES_PATCH) | patch -d $(EBTABLES_DIR) -p1
	touch $(EBTABLES_DIR)/.source

source: $(EBTABLES_DIR)/.source

$(EBTABLES_DIR)/.build: $(EBTABLES_DIR)/.source
	mkdir -p $(EBTABLES_TARGET_DIR)/usr/sbin
	mkdir -p $(EBTABLES_TARGET_DIR)/usr/lib
	mkdir -p $(EBTABLES_TARGET_DIR)/etc

	make $(MAKEOPTS) -C $(EBTABLES_DIR) CC=$(TARGET_CC) CFLAGS="$(CFLAGS)" \
	BINDIR=/usr/sbin MANDIR=/usr/man LIBDIR=/usr/lib

	cp -a $(EBTABLES_DIR)/ebtables $(EBTABLES_TARGET_DIR)/usr/sbin/
	cp -a $(EBTABLES_DIR)/*.so $(EBTABLES_TARGET_DIR)/usr/lib/
	cp -a $(EBTABLES_DIR)/extensions/*.so $(EBTABLES_TARGET_DIR)/usr/lib/
	cp -a $(EBTABLES_DIR)/ethertypes $(EBTABLES_TARGET_DIR)/etc
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(EBTABLES_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(EBTABLES_TARGET_DIR)/usr/lib/*
	cp -a $(EBTABLES_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(EBTABLES_DIR)/.build

build: $(EBTABLES_DIR)/.build

clean:
	make -C $(EBTABLES_DIR) clean
	rm -rf $(EBTABLES_TARGET_DIR)
	rm -rf $(EBTABLES_DIR)/.build
	rm -rf $(EBTABLES_DIR)/.configured

srcclean: clean
	rm -rf $(EBTABLES_DIR)
