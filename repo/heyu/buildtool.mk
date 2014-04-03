############################################
# makefile for heyu
###########################################

HEYU_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(HEYU_SOURCE) 2>/dev/null)
HEYU_TARGET_DIR:=$(BT_BUILD_DIR)/heyu

$(HEYU_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(HEYU_SOURCE)
	touch $(HEYU_DIR)/.source

source: $(HEYU_DIR)/.source

$(HEYU_DIR)/.configured: $(HEYU_DIR)/.source
	(cd $(HEYU_DIR); ./configure \
	--prefix=/ \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME))
	touch $(HEYU_DIR)/.configured

$(HEYU_DIR)/.build: $(HEYU_DIR)/.configured
	mkdir -p $(HEYU_TARGET_DIR)
	mkdir -p $(HEYU_TARGET_DIR)/usr/bin
	mkdir -p $(HEYU_TARGET_DIR)/etc/heyu
	mkdir -p $(HEYU_TARGET_DIR)/etc/init.d

	make $(MAKEOPTS) -C $(HEYU_DIR) DESTDIR=$(HEYU_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS)" all
	cp -a $(HEYU_DIR)/heyu $(HEYU_TARGET_DIR)/usr/bin
	cp -a $(HEYU_DIR)/x10config.sample $(HEYU_TARGET_DIR)/etc/heyu/x10.conf
	cp -a $(HEYU_DIR)/x10.sched.sample $(HEYU_TARGET_DIR)/etc/heyu/x10.sched
	cp -aL heyu.init $(HEYU_TARGET_DIR)/etc/init.d/heyu
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HEYU_TARGET_DIR)/usr/bin/*
	cp -a $(HEYU_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(HEYU_DIR)/.build

build: $(HEYU_DIR)/.build

clean:
	make -C $(HEYU_DIR) clean
	rm -rf $(HEYU_TARGET_DIR)
	rm -rf $(HEYU_DIR)/.build
	rm -rf $(HEYU_DIR)/.configured

srcclean: clean
	rm -rf $(HEYU_DIR)
