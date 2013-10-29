# makefile for pump

PUMP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(PUMP_SOURCE) 2>/dev/null )
PUMP_TARGET_DIR:=$(BT_BUILD_DIR)/pump

export LDFLAGS += $(EXTCCLDFLAGS)

$(PUMP_DIR)/.source:
	tar xvzf $(PUMP_SOURCE)
	zcat $(PUMP_PATCH1) | patch -d $(PUMP_DIR) -p1
	perl -i -p -e 's,-Wl\S+,,g' $(PUMP_DIR)/Makefile
	touch $(PUMP_DIR)/.source

source: $(PUMP_DIR)/.source

$(PUMP_DIR)/.build: $(PUMP_DIR)/.source
	mkdir -p $(PUMP_TARGET_DIR)
	mkdir -p $(PUMP_TARGET_DIR)/etc/
	mkdir -p $(PUMP_TARGET_DIR)/sbin
	make $(MAKEOPTS) -C $(PUMP_DIR) CC=$(TARGET_CC) LDFLAGS="$(LDFLAGS)" \
	DEB_CFLAGS="$(CFLAGS)" pump
	cp -a $(PUMP_DIR)/pump $(PUMP_TARGET_DIR)/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PUMP_TARGET_DIR)/sbin/*
	cp -aL pump.shorewall $(PUMP_TARGET_DIR)/etc
	cp -aL pump.conf $(PUMP_TARGET_DIR)/etc
	cp -a $(PUMP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PUMP_DIR)/.build


build: $(PUMP_DIR)/.build

clean:
	make -C $(PUMP_DIR) clean
	rm -rf $(PUMP_DIR)/.build
	rm -rf $(PUMP_DIR)/.configured

srcclean: clean
	rm -rf $(PUMP_DIR)
