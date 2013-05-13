# makefile for accel-pptp

ACCEL_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(ACCEL_SOURCE) 2>/dev/null )
ACCEL_TARGET_DIR:=$(BT_BUILD_DIR)/accel-ppp

$(ACCEL_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(ACCEL_SOURCE)
#	perl -i -p -e 's,#include\s*\<printf.h\>,,' $(ACCEL_DIR)/accel-pppd/ctrl/pppoe/pppoe.c
#	cat $(PATCH1) | patch -p1 -d $(ACCEL_DIR)
	touch $@

source: $(ACCEL_DIR)/.source

$(ACCEL_DIR)/.configured: $(ACCEL_DIR)/.source
	(cd $(ACCEL_DIR); cmake \
	    -DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
	    -DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
	    -DCMAKE_FIND_ROOT_PATH="$(BT_TOOLCHAIN_DIR) $(BT_STAGING_DIR)" \
	    -DCMAKE_SYSTEM_NAME=Linux \
	    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
	    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
	    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
	    -DKDIR=$(BT_SOURCE_DIR)/linux/linux \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLOG_FILE=FALSE \
	    -DSHAPER=TRUE \
	    -DRADIUS=TRUE \
	    -DNETSNMP=TRUE \
	    -DCMAKE_INSTALL_PREFIX=/usr \
	    .)
	touch $@

$(ACCEL_DIR)/.build: $(ACCEL_DIR)/.configured
	mkdir -p $(ACCEL_TARGET_DIR)/etc/init.d

	$(MAKE) -C $(ACCEL_DIR)
	$(MAKE) -C $(ACCEL_DIR) install DESTDIR=$(ACCEL_TARGET_DIR)
	cp -aL accel-ppp.conf $(ACCEL_TARGET_DIR)/etc
	cp -aL accel-ppp.init $(ACCEL_TARGET_DIR)/etc/init.d/accel-ppp
	cp -aL dictionary.abills $(ACCEL_TARGET_DIR)/usr/share/accel-ppp/radius
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ACCEL_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ACCEL_TARGET_DIR)/usr/lib/accel-ppp/*
	rm -rf $(ACCEL_TARGET_DIR)/usr/share/man
	cp -a $(ACCEL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ACCEL_DIR)/.build

build: $(ACCEL_DIR)/.build

clean:
	rm -rf $(ACCEL_TARGET_DIR)
	$(MAKE) -C $(ACCEL_DIR) clean
	rm -f $(ACCEL_DIR)/.build

srcclean: clean
	rm -rf $(ACCEL_DIR)
