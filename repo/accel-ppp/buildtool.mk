# makefile for accel-pptp

ACCEL_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(ACCEL_SOURCE) 2>/dev/null )
ACCEL_TARGET_DIR:=$(BT_BUILD_DIR)/accel-ppp

$(ACCEL_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(ACCEL_SOURCE)
	perl -i -p -e 's,#include\s*\<printf.h\>,,' $(ACCEL_DIR)/accel-pppd/ctrl/pppoe/pppoe.c
#	cat $(PATCH1) | patch -p1 -d $(ACCEL_DIR)
	touch $@

source: $(ACCEL_DIR)/.source

$(ACCEL_DIR)/.kbuild: $(ACCEL_DIR)/.source
	for i in $(KARCHS); do \
	    mkdir -p $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/extra && \
	    KDIR=$(BT_SOURCE_DIR)/linux/linux make -C $(BT_SOURCE_DIR)/linux/linux-$$i M=$(ACCEL_DIR)/drivers/ipoe && \
	    gzip -9 $(ACCEL_DIR)/drivers/ipoe/ipoe.ko && \
	    mv -f $(ACCEL_DIR)/drivers/ipoe/ipoe.ko.gz $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/extra && \
	    depmod -ae -b $(BT_STAGING_DIR) -r -F $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/build/System.map $(BT_KERNEL_RELEASE)-$$i; \
	done
	touch $(ACCEL_DIR)/.kbuild

$(ACCEL_DIR)/.build: $(ACCEL_DIR)/.source
	mkdir -p $(ACCEL_TARGET_DIR)/etc/init.d
	mkdir -p $(ACCEL_TARGET_DIR)/etc/default

	(cd $(ACCEL_DIR); rm -rf CMakeFiles; cmake \
	    -DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
	    -DCMAKE_FIND_ROOT_PATH="$(BT_TOOLCHAIN_DIR) $(BT_STAGING_DIR)" \
	    -DCMAKE_SYSTEM_NAME=Linux \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLOG_FILE=FALSE \
	    -DSHAPER=TRUE \
	    -DRADIUS=TRUE \
	    -DNETSNMP=TRUE \
	    -DLUA=TRUE \
	    -DLUA_INCLUDE_DIR="$(BT_STAGING_DIR)/usr/include" \
	    -DLUA_LIBRARIES="$(BT_STAGING_DIR)/usr/lib/liblua.a" \
	    -DCMAKE_INSTALL_PREFIX=/usr \
	    -DLIB_SUFFIX="" \
	    .)
	$(MAKE) $(MAKEOPTS) -C $(ACCEL_DIR)
	$(MAKE) -C $(ACCEL_DIR) install DESTDIR=$(ACCEL_TARGET_DIR)
	cp -aL accel-ppp.conf accel-ppp.lua $(ACCEL_TARGET_DIR)/etc
	cp -aL accel-ppp.init $(ACCEL_TARGET_DIR)/etc/init.d/accel-ppp
	cp -aL accel-ppp.default $(ACCEL_TARGET_DIR)/etc/default/accel-ppp
	cp -aL dictionary.abills $(ACCEL_TARGET_DIR)/usr/share/accel-ppp/radius
#	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ACCEL_TARGET_DIR)/usr/sbin/*
#	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ACCEL_TARGET_DIR)/usr/lib/accel-ppp/*
	rm -rf $(ACCEL_TARGET_DIR)/usr/share/man
	cp -a $(ACCEL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ACCEL_DIR)/.build

build: $(ACCEL_DIR)/.build $(ACCEL_DIR)/.kbuild

kbuild: $(ACCEL_DIR)/.kbuild

clean:
	rm -rf $(ACCEL_TARGET_DIR)
	$(MAKE) -C $(ACCEL_DIR) clean
	rm -f $(ACCEL_DIR)/.build

srcclean: clean
	rm -rf $(ACCEL_DIR)
