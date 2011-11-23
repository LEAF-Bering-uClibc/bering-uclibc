# makefile for pmacctd
include $(MASTERMAKEFILE)

KNOCKD_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(KNOCKD_SOURCE) 2>/dev/null )
ifeq ($(KNOCKD_DIR),)
KNOCKD_DIR:=$(shell cat DIRNAME)
endif
KNOCKD_TARGET_DIR:=$(BT_BUILD_DIR)/knockd

$(KNOCKD_DIR)/.source:
	zcat $(KNOCKD_SOURCE) | tar -xvf -
	echo $(KNOCKD_DIR) > DIRNAME
	touch $(KNOCKD_DIR)/.source

source: $(KNOCKD_DIR)/.source

$(KNOCKD_DIR)/.configured: $(KNOCKD_DIR)/.source
	(cd $(KNOCKD_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CXXFLAGS=-I$(BT_STAGING_DIR)/usr/include ./configure --prefix=/usr  )
	touch $(KNOCKD_DIR)/.configured

$(KNOCKD_DIR)/.build: $(KNOCKD_DIR)/.configured
	mkdir -p $(KNOCKD_TARGET_DIR)
	mkdir -p $(KNOCKD_TARGET_DIR)/etc/init.d
	mkdir -p $(KNOCKD_TARGET_DIR)/etc/default
	mkdir -p $(KNOCKD_TARGET_DIR)/usr/sbin
	make -C $(KNOCKD_DIR) CXXFLAGS=-I$(BT_STAGING_DIR)/usr/include all
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(KNOCKD_DIR)/knockd
	cp -aL knockd.init $(KNOCKD_TARGET_DIR)/etc/init.d/knockd
	cp -aL knockd.conf $(KNOCKD_TARGET_DIR)/etc
	cp -aL knockd.default $(KNOCKD_TARGET_DIR)/etc/default/knockd
	cp -a $(KNOCKD_DIR)/knockd $(KNOCKD_TARGET_DIR)/usr/sbin
	cp -a $(KNOCKD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(KNOCKD_DIR)/.build

build: $(KNOCKD_DIR)/.build

clean:
	make -C $(KNOCKD_DIR) clean
	rm -rf $(KNOCKD_TARGET_DIR)
	rm -rf $(KNOCKD_DIR)/.build
	rm -rf $(KNOCKD_DIR)/.configured

srcclean: clean
	rm -rf $(KNOCKD_DIR)
