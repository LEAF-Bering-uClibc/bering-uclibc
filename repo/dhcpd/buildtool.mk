#############################################################
#
# buildtool makefile for dhcpd
#
#############################################################

include $(MASTERMAKEFILE)

DHCPD_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(DHCPD_DIR),)
DHCPD_DIR:=$(shell cat DIRNAME)
endif
DHCPD_TARGET_DIR:=$(BT_BUILD_DIR)/dhcpd

# Option settings for 'configure':
#   Move default install from /usr/local to /
#   Disable included BIND (we really need it? If yes - add it into deps)
CONFOPTS:= --host=$(GNU_TARGET_NAME) --prefix=/ --without-libbind

.source:
	zcat $(SOURCE) | tar -xvf -
	echo $(DHCPD_DIR) > DIRNAME
	touch .source

source: .source

.configure: .source
	( cd $(DHCPD_DIR); ./configure $(CONFOPTS) );
	touch .configure

.build: .configure
	mkdir -p $(DHCPD_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/bin/
	mkdir -p $(BT_STAGING_DIR)/sbin/
	mkdir -p $(BT_STAGING_DIR)/lib/
	mkdir -p $(BT_STAGING_DIR)/include/
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	mkdir -p $(BT_STAGING_DIR)/etc/default/
#
	make $(MAKEOPTS) -C $(DHCPD_DIR)/server
	make $(MAKEOPTS) -C $(DHCPD_DIR)/omapip
	exit
	make DESTDIR=$(DHCPD_TARGET_DIR) -C $(DHCPD_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DHCPD_TARGET_DIR)/bin/*
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DHCPD_TARGET_DIR)/sbin/*
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(DHCPD_TARGET_DIR)/lib/*
	cp -a $(DHCPD_TARGET_DIR)/bin/* $(BT_STAGING_DIR)/bin/
	cp -a $(DHCPD_TARGET_DIR)/sbin/* $(BT_STAGING_DIR)/sbin/
	cp -a $(DHCPD_TARGET_DIR)/lib/* $(BT_STAGING_DIR)/lib/
	cp -a $(DHCPD_TARGET_DIR)/include/* $(BT_STAGING_DIR)/include/
	cp -L dhcpd.conf $(BT_STAGING_DIR)/etc/
	cp -L dhcpd6.conf $(BT_STAGING_DIR)/etc/
	cp -L iscdhcp-server.init $(BT_STAGING_DIR)/etc/init.d/iscdhcp-server
	cp -L iscdhcp-server.default $(BT_STAGING_DIR)/etc/default/iscdhcp-server
	touch .build

build: .build

clean:
	make -C $(DHCPD_DIR) clean
	rm -rf $(DHCPD_TARGET_DIR)
	-rm .build .configure

srcclean: clean
	rm -rf $(DHCPD_DIR) 
	rm DIRNAME
	rm .source

