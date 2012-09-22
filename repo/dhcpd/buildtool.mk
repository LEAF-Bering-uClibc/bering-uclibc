################################################################################
#
# buildtool makefile for dhcpd
#
#  Cross-compiling notes  2012-03-24  dMb:
#    The included copy of 'bind' is not cross-compile friendly.
#    This is acknowldged in the README (section for SOLARIS):
#     > makefiles for the Bind libraries.  Currently we don't pass all
#     > environment variables between the DHCP configure and the Bind configure.
#    As a result it is necessary to force CC to be the *target* CC so that the
#    included copy of bind is built for the target platform.
#    The problem then is that it doesn't spot that it is being cross-compiled
#    so we need to force the specification of --host for bind's configure.
#    And *then* the problem is that the "gen" utility needs to run on the
#    build host, so it needs to be compiled with BUILD_CC rather than CC.
#
################################################################################

include $(MASTERMAKEFILE)

DHCPD_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
DHCPD_TARGET_DIR:=$(BT_BUILD_DIR)/dhcpd

# Option settings for 'configure':
#   Move default install from /usr/local to /
CONFOPTS:= --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) --prefix=/

.source:
	zcat $(SOURCE) | tar -xvf -
	# Force use of local bind include files before staging include files
	for dir in common omapip client relay; do perl -i -p -e 's,^DEFAULT_INCLUDES = ,DEFAULT_INCLUDES = -I../bind/include ,' $(DHCPD_DIR)/$$dir/Makefile.in; done
	# Force cross-compile for local copy of bind
	perl -i -p -e 's, ./configure , ./configure --host=$(GNU_TARGET_NAME) ,' $(DHCPD_DIR)/bind/Makefile
	# Force early unpacking of bind.tar.gz so we can hack it
	( cd $(DHCPD_DIR)/bind ; zcat bind.tar.gz | tar -xvf - )
	# Force use of BUILD_CC for "gen" utility which runs on build host
	( cd $(DHCPD_DIR)/bind ; perl -i -p -e 's,CC}.*srcdir}/gen.c,BUILD_CC} -I\$$\{srcdir\}/../isc/include -o \$$\@ \$$\{srcdir\}/gen.c,' bind-*/lib/export/dns/Makefile.in )
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
	# Need to force setting of CC for included copy of bind - see README
	CC=$(BT_TOOLCHAIN_DIR)/bin/$(GNU_TARGET_NAME)-gcc BUILD_CC=gcc make -C $(DHCPD_DIR)
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
	rm .source

