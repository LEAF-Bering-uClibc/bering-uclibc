#############################################################
#
# nut
#
# $Id: buildtool.mk,v 1.6 2010/11/06 21:28:34 davidmbrooke Exp $
#############################################################

include $(MASTERMAKEFILE)
NUT_DIR:=nut-2.4.3
NUT_TARGET_DIR:=$(BT_BUILD_DIR)/nut


.source: 
	zcat $(SOURCE) |  tar -xvf -
	cat $(PATCH1) | patch -d $(NUT_DIR) -p1
	cat $(PATCH2) | patch -d $(NUT_DIR) -p1
	touch .source
#	cp $(MKFILE) $(NUT_DIR)/Makefile

source: .source

$(NUT_DIR)/Makefile: .source
	(cd $(NUT_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	CFLAGS="$(BT_COPT_FLAGS) -g -Wall" LIBS="-lm" \
	LIBC_INCLUDE=$(BT_STAGING_DIR)/include \
	KERNEL_INCLUDE=$(BT_LINUX_DIR)-$(BT_KERNEL_VERSION)/include \
	./configure --prefix=/usr \
	--sysconfdir=/etc/nut \
	--localstatedir=/var/run \
	--with-usb \
	--with-usb-includes='-I$(BT_STAGING_DIR)/usr/include' \
	--with-usb-libs='-L$(BT_STAGING_DIR)/usr/lib -lusb' \
	--with-snmp \
	--with-snmp-includes='-I$(BT_STAGING_DIR)/usr/include' \
	--with-snmp-libs='-L$(BT_STAGING_DIR)/usr/lib -lnetsnmp' \
	--with-drivers=all \
	$(NULL); cd drivers; BT_ST_DIR=$(BT_STAGING_DIR) sh ../../patch-mkfile)	
#	touch $(NUT_DIR)/.configured


build: $(NUT_DIR)/Makefile
	mkdir -p $(NUT_TARGET_DIR)
	mkdir -p $(NUT_TARGET_DIR)/etc/
	$(MAKE) KERNEL_INCLUDE=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/include  \
		LIBC_INCLUDE=$(BT_STAGING_DIR)/include \
		CC=$(TARGET_CC) \
		CCOPTS="-D_GNU_SOURCE $(BT_COPT_FLAGS) -Wstrict-prototypes -Wall " \
		-C $(NUT_DIR) 
	$(MAKE) DESTDIR=$(NUT_TARGET_DIR) -C $(NUT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NUT_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NUT_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(NUT_TARGET_DIR)/usr/lib/libupsclient.so.1.0.0
	rm -rf $(NUT_TARGET_DIR)/lib
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
