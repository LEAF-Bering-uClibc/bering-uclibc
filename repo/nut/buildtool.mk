#############################################################
#
# nut
#
# $Id: buildtool.mk,v 1.6 2010/11/06 21:28:34 davidmbrooke Exp $
#############################################################

include $(MASTERMAKEFILE)
NUT_DIR:=nut-2.6.2
NUT_TARGET_DIR:=$(BT_BUILD_DIR)/nut


.source: 
	zcat $(SOURCE) |  tar -xvf -
#	cat $(PATCH1) | patch -d $(NUT_DIR) -p1
	cat $(PATCH2) | patch -d $(NUT_DIR) -p1
	touch .source
#	cp $(MKFILE) $(NUT_DIR)/Makefile

source: .source
# LIBC_INCLUDE=$(BT_STAGING_DIR)/usr/include
$(NUT_DIR)/Makefile: .source
	(cd $(NUT_DIR) ; PKG_CONFIG_LIBDIR=$(BT_STAGING_DIR)/usr/lib LIBS=-lm \
	KERNEL_INCLUDE=$(BT_LINUX_DIR)-$(BT_KERNEL_VERSION)/include \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--sysconfdir=/etc/nut \
	--localstatedir=/var/run \
	--with-usb \
	--with-usb-includes=-I$(BT_STAGING_DIR)/usr/include \
	--with-usb-libs=-lusb \
	--with-snmp \
	--with-snmp-includes=-I$(BT_STAGING_DIR)/usr/include \
	--with-snmp-libs=-lnetsnmp \
	--with-ssl \
	--with-ssl-includes=-I$(BT_STAGING_DIR)/usr/include \
	--without-wrap \
	--without-cgi --without-avahi --without-hal \
	--without-ipmi --without-freeipmi --without-powerman \
	--with-drivers=all)
#	touch $(NUT_DIR)/.configured


build: $(NUT_DIR)/Makefile
	mkdir -p $(NUT_TARGET_DIR)
	mkdir -p $(NUT_TARGET_DIR)/etc/
	$(MAKE) $(MAKEOPTS) -C $(NUT_DIR)/common
	$(MAKE) $(MAKEOPTS) -C $(NUT_DIR)/clients
	$(MAKE) $(MAKEOPTS) -C $(NUT_DIR)/server
	$(MAKE) $(MAKEOPTS) -C $(NUT_DIR)/drivers
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/common install
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/clients install
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/server install
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/drivers install
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/include install
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/data install
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR)/conf install
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(NUT_TARGET_DIR)/usr/lib/*.la
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NUT_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NUT_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(NUT_TARGET_DIR)/usr/lib/libupsclient.so.1.0.0
	rm -rf $(NUT_TARGET_DIR)/usr/cgi-bin
	rm -rf $(NUT_TARGET_DIR)/usr/html
	rm -rf $(NUT_TARGET_DIR)/usr/lib/pkgconfig
	rm -rf $(NUT_TARGET_DIR)/usr/share/man
	mkdir -p $(NUT_TARGET_DIR)/etc/init.d
	mkdir -p $(NUT_TARGET_DIR)/etc/default
	cp -aL upsd.init $(NUT_TARGET_DIR)/etc/init.d/upsd
	cp -aL upsmon.init $(NUT_TARGET_DIR)/etc/init.d/upsmon
	cp -aL upsd.default $(NUT_TARGET_DIR)/etc/default/upsd
	cp -aL upsmon.default $(NUT_TARGET_DIR)/etc/default/upsmon
	cp -a $(NUT_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	-rm -f $(NUT_DIR)/bin/*
 
srcclean:
	rm -rf $(NUT_DIR)
	rm .source
