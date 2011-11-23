#############################################################
#
# mtools
#
#############################################################

include $(MASTERMAKEFILE)
MTOOLS_DIR:=mtools-3.9.9
MTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/mtools
export CC=$(TARGET_CC)


$(MTOOLS_DIR)/.source:
	zcat $(MTOOLS_SOURCE) |  tar -xvf -
	zcat $(MTOOLS_PATCH1) | patch -d $(MTOOLS_DIR) -p1
	touch $(MTOOLS_DIR)/.source

$(MTOOLS_DIR)/.configured: $(MTOOLS_DIR)/.source

	( cd $(MTOOLS_DIR) ; CFLAGS="$(BT_COPT_FLAGS) -Wall" ./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--target=$(GNU_HOST_NAME) \
		--disable-floppyd \
		--disable-debug \
		--disable-new-vold \
		--disable-vold 	;)
	touch $(MTOOLS_DIR)/.configured

$(MTOOLS_DIR)/.build: $(MTOOLS_DIR)/.configured
	mkdir -p $(MTOOLS_TARGET_DIR)/etc
	$(MAKE) $(MAKEOPTS) -C $(MTOOLS_DIR)
	$(MAKE) prefix=$(MTOOLS_TARGET_DIR)/usr -C $(MTOOLS_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MTOOLS_TARGET_DIR)/usr/bin/*
	-rm -rf $(MTOOLS_TARGET_DIR)/usr/info $(MTOOLS_TARGET_DIR)/usr/man
	cp $(MTOOLS_DIR)/debian/mtools.conf $(MTOOLS_TARGET_DIR)/etc/
	cp -a $(MTOOLS_TARGET_DIR)/*  $(BT_STAGING_DIR)/
	touch $(MTOOLS_DIR)/.build

source: $(MTOOLS_DIR)/.source

build: $(MTOOLS_DIR)/.build

clean:
	rm -rf $(MTOOLS_TARGET_DIR)
	-rm $(MTOOLS_DIR)/.build
	$(MAKE) -C $(MTOOLS_DIR) clean

srcclean:
	rm -rf $(MTOOLS_DIR)
