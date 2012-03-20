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
CONFOPTS:= --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) --prefix=/

.source:
	zcat $(SOURCE) | tar -xvf -
	echo $(DHCPD_DIR) > DIRNAME
	# Force use of local bind include files before staging include files
	for dir in common omapip client relay; do perl -i -p -e 's,^DEFAULT_INCLUDES = ,DEFAULT_INCLUDES = -I../bind/include ,' $(DHCPD_DIR)/$$dir/Makefile.in; done
	touch .source

source: .source

.configure: .source
	# Need to force setting of CC for included copy of bind - see README
	( cd $(DHCPD_DIR); CC=$(TOOLCHAIN_DIR)/bin/$(GNU_TARGET_NAME)-gcc ./configure $(CONFOPTS) );
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
	# Need to force setting of CC for included copy of bind - see README
	CC=$(TOOLCHAIN_DIR)/bin/$(GNU_TARGET_NAME)-gcc make -C $(DHCPD_DIR)
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

