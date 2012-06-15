# makefile for ndppd
include $(MASTERMAKEFILE)

NDPPD_DIR:=ndppd-0.2.2
NDPPD_TARGET_DIR:=$(BT_BUILD_DIR)/ndppd

$(NDPPD_DIR)/.source:
	zcat $(NDPPD_SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(NDPPD_DIR)
	touch $(NDPPD_DIR)/.source

source: $(NDPPD_DIR)/.source

$(NDPPD_DIR)/.configured: $(NDPPD_DIR)/.source
	touch $(NDPPD_DIR)/.configured

$(NDPPD_DIR)/.build: $(NDPPD_DIR)/.configured
	mkdir -p $(NDPPD_TARGET_DIR)
	mkdir -p $(NDPPD_TARGET_DIR)/usr/sbin
	mkdir -p $(NDPPD_TARGET_DIR)/etc/init.d
	make -C $(NDPPD_DIR) DESTDIR=$(NDPPD_TARGET_DIR) \
	CXXFLAGS="$(BT_COPT_FLAGS)" CXX=$(BT_STAGING_DIR)/usr/bin/g++ \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS) -DNO_TFTP" all
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(NDPPD_DIR)/ndppd
	cp -aL ndppd.init $(NDPPD_TARGET_DIR)/etc/init.d/ndppd
	cp -a $(NDPPD_DIR)/ndppd $(NDPPD_TARGET_DIR)/usr/sbin
	cp -a $(NDPPD_DIR)/ndppd.conf-dist $(NDPPD_TARGET_DIR)/etc/ndppd.conf
	cp -a $(NDPPD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(NDPPD_DIR)/.build

build: $(NDPPD_DIR)/.build

clean:
	make -C $(NDPPD_DIR) clean
	rm -rf $(NDPPD_TARGET_DIR)
	rm -rf $(NDPPD_DIR)/.build
	rm -rf $(NDPPD_DIR)/.configured

srcclean: clean
	rm -rf $(NDPPD_DIR)
