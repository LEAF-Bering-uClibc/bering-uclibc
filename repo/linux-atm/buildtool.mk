################################################################################
#
# buildtool makefile for linux-atm
#
# Cross-compiling notes  2012-03-24  dMb:
#   The build process creates a program called qgen which is executed as 
#   part of the build. This needs to be built using the *build* platform
#   compiler rather than the *target* platform compiler. As a result
#   src/qgen/Makefile.in specifies the use of BUILD_CC rather than CC.
#   The ld command line for qgen specifies -lfl so this (flex) library must
#   be present on the build host. On x86_64 Fedora this required the
#   installation of RPM flex-static (yum install flex-static)
#
################################################################################

include $(MASTERMAKEFILE)

ATM_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(ATM_DIR),)
ATM_DIR:=$(shell cat DIRNAME)
endif
ATM_TARGET_DIR:=$(BT_BUILD_DIR)/linuxatm

.source:
	zcat $(SOURCE) | tar -xvf -
	echo $(ATM_DIR) > DIRNAME
	touch .source

source: .source

.configure: .source
	(cd $(ATM_DIR) ; CFLAGS="$(CFLAGS)" \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--sysconfdir=/etc \
	--oldincludedir=$(BT_STAGING_DIR)/include )
	touch .configure

.build: .configure
	mkdir -p $(ATM_TARGET_DIR)
	mkdir -p $(ATM_TARGET_DIR)/etc/init.d
	# Multi-threaded make fails so don't specify $(MAKEOPTS)
	make -C $(ATM_DIR)
	make -C $(ATM_DIR) DESTDIR=$(ATM_TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ATM_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ATM_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ATM_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(ATM_TARGET_DIR)/usr/lib/*.la
	-rm -rf $(ATM_TARGET_DIR)/usr/share
	cp -aL atmsigd.conf $(ATM_TARGET_DIR)/etc
	cp -aL atm.init $(ATM_TARGET_DIR)/etc/init.d/atm
	cp -a $(ATM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	(cd $(ATM_DIR); make clean)
	rm -rf $(ATM_TARGET_DIR)
	rm -f .build
	rm -f .configure

srcclean: clean
	rm -rf $(ATM_DIR)
	rm DIRNAME
	rm -f .source
