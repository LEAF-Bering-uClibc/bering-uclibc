# makefile for rng-tools

RNGTOOLS_DIR:= rng-tools-4
RNGTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/rng-tools

$(RNGTOOLS_DIR)/.source:
	zcat $(RNGTOOLS_SOURCE) | tar -xvf -
	touch $(RNGTOOLS_DIR)/.source

source: $(RNGTOOLS_DIR)/.source

$(RNGTOOLS_DIR)/.configured: $(RNGTOOLS_DIR)/.source
	(cd $(RNGTOOLS_DIR) ; \
		LIBS=-largp ./configure --prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME)) 
	touch $(RNGTOOLS_DIR)/.configured

$(RNGTOOLS_DIR)/.build: $(RNGTOOLS_DIR)/.configured
	mkdir -p $(RNGTOOLS_TARGET_DIR)
	mkdir -p $(RNGTOOLS_TARGET_DIR)/usr/sbin
	mkdir -p $(RNGTOOLS_TARGET_DIR)/usr/bin
	mkdir -p $(RNGTOOLS_TARGET_DIR)/etc/init.d  
	make $(MAKEOPTS) -C $(RNGTOOLS_DIR)
	cp -a $(RNGTOOLS_DIR)/rngd $(RNGTOOLS_TARGET_DIR)/usr/bin
	cp -a $(RNGTOOLS_DIR)/rngtest $(RNGTOOLS_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(RNGTOOLS_TARGET_DIR)/usr/bin/*
	cp -aL rngd.init $(RNGTOOLS_TARGET_DIR)/etc/init.d/
	cp -a $(RNGTOOLS_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(RNGTOOLS_DIR)/.build

build: $(RNGTOOLS_DIR)/.build

clean:
	make -C $(RNGTOOLS_DIR) clean
	rm -rf $(RNGTOOLS_TARGET_DIR)
	rm -f $(RNGTOOLS_DIR)/.build
	rm -f $(RNGTOOLS_DIR)/.configured

srcclean: clean
	rm -rf $(RNGTOOLS_DIR)
