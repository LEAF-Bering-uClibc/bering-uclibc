# makefile for linux-atm
include $(MASTERMAKEFILE)

ATM_DIR:=linux-atm-2.5.1
ATM_TARGET_DIR:=$(BT_BUILD_DIR)/linuxatm

$(ATM_DIR)/.source:
	zcat $(ATM_SOURCE) | tar -xvf -
#	zcat $(ATM_PATCH1) | patch -d $(ATM_DIR) -p1
	touch $(ATM_DIR)/.source

source: $(ATM_DIR)/.source

$(ATM_DIR)/.configured: $(ATM_DIR)/.source
	#perl -i -p -e 's,/usr/include/asm/errno.h,$(BT_STAGING_DIR)/include/asm/errno.h,g' $(ATM_DIR)/src/test/Makefile.in
	(cd $(ATM_DIR) ; ./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--sysconfdir=/etc --oldincludedir=$(BT_STAGING_DIR)/include )
	touch $(ATM_DIR)/.configured

$(ATM_DIR)/.build: $(ATM_DIR)/.configured
	mkdir -p $(ATM_TARGET_DIR)
	mkdir -p $(ATM_TARGET_DIR)/etc/init.d
	make $(MAKEOPTS) -C $(ATM_DIR)
	make $(MAKEOPTS) -C $(ATM_DIR) DESTDIR=$(ATM_TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ATM_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ATM_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ATM_TARGET_DIR)/usr/lib
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(ATM_TARGET_DIR)/usr/lib/*.la
	-rm -rf $(ATM_TARGET_DIR)/usr/share
	cp -aL atmsigd.conf $(ATM_TARGET_DIR)/etc
	cp -aL atm.init $(ATM_TARGET_DIR)/etc/init.d/atm
	cp -a $(ATM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ATM_DIR)/.build

build: $(ATM_DIR)/.build

clean:
	rm -rf $(ATM_TARGET_DIR)
	(cd $(ATM_DIR); make distclean)
	rm -f $(ATM_DIR)/.build
	rm -f $(ATM_DIR)/.configured

srcclean: clean
	rm -rf $(ATM_DIR)
