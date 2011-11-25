# makefile for bpalogin
include $(MASTERMAKEFILE)

BPALOGIN_DIR:=bpalogin-2.0.2
BPALOGIN_TARGET_DIR:=$(BT_BUILD_DIR)/bpalogin

$(BPALOGIN_DIR)/.source:
	zcat $(BPALOGIN_SOURCE) | tar -xvf -
	touch $(BPALOGIN_DIR)/.source

source: $(BPALOGIN_DIR)/.source

$(BPALOGIN_DIR)/.configured: $(BPALOGIN_DIR)/.source
	(cd $(BPALOGIN_DIR) ; ./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) )
	touch $(BPALOGIN_DIR)/.configured

$(BPALOGIN_DIR)/.build: $(BPALOGIN_DIR)/.configured
	mkdir -p $(BPALOGIN_TARGET_DIR)
	mkdir -p $(BPALOGIN_TARGET_DIR)/etc/init.d
	mkdir -p $(BPALOGIN_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(BPALOGIN_DIR) DESTDIR=$(BPALOGIN_TARGET_DIR)
	cp -aL bpalogin.init $(BPALOGIN_TARGET_DIR)/etc/init.d/bpalogin
	cp -a $(BPALOGIN_DIR)/bpalogin.conf $(BPALOGIN_TARGET_DIR)/etc/
	cp -a $(BPALOGIN_DIR)/bpalogin $(BPALOGIN_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BPALOGIN_TARGET_DIR)/usr/sbin/*
	cp -a $(BPALOGIN_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(BPALOGIN_DIR)/.build

build: $(BPALOGIN_DIR)/.build

clean:
	make -C $(BPALOGIN_DIR) clean
	rm -rf $(BPALOGIN_TARGET_DIR)
	rm -f $(BPALOGIN_DIR)/.build
	rm -f $(BPALOGIN_DIR)/.configured

srcclean: clean
	rm -rf $(BPALOGIN_DIR)
