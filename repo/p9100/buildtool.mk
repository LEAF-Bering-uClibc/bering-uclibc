# makefile for p9100

P9100_DIR:=p910nd-0.95
P9100_TARGET_DIR:=$(BT_BUILD_DIR)/p9100

$(P9100_DIR)/.source:
	bzcat $(P9100_SOURCE) | tar -xvf -
	touch $(P9100_DIR)/.source

source: $(P9100_DIR)/.source

$(P9100_DIR)/.configured: $(P9100_DIR)/.source
	touch $(P9100_DIR)/.configured

$(P9100_DIR)/.build: $(P9100_DIR)/.configured
	mkdir -p $(P9100_TARGET_DIR)
	mkdir -p $(P9100_TARGET_DIR)/etc/init.d
	mkdir -p $(P9100_TARGET_DIR)/etc/default
	mkdir -p $(P9100_TARGET_DIR)/usr/sbin
	make CROSS=$(CROSS_COMPILE) -C $(P9100_DIR) CFLAGS="$(CFLAGS) -DLOCKFILE_DIR=\\"\"/var/lock\\"\""
	cp -a $(P9100_DIR)/p910nd $(P9100_TARGET_DIR)/usr/sbin
	cp -aL p910nd.init $(P9100_TARGET_DIR)/etc/init.d/p910nd
	cp -aL p910nd.default $(P9100_TARGET_DIR)/etc/default/p910nd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(P9100_TARGET_DIR)/usr/sbin/*
	cp -a $(P9100_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(P9100_DIR)/.build

build: $(P9100_DIR)/.build

clean:
	rm -rf $(P9100_TARGET_DIR)
	rm $(P9100_DIR)/p910nd
	rm $(P9100_DIR)/.build
	rm $(P9100_DIR)/.configured

srcclean:
	rm -rf $(P9100_DIR)
