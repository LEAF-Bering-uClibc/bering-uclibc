#############################################################
#
# net-snmp
#
# $Id: buildtool.mk,v 1.4 2010/07/22 19:14:00 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

SNMP_DIR:=net-snmp-5.7.1
SNMP_TARGET_DIR:=$(BT_BUILD_DIR)/net-snmp

export CFLAGS += -D_REENTRANT
MIB_MODULES = host smux ucd-snmp/dlmod ucd-snmp/lmsensorsMib

$(SNMP_DIR)/.source:
	zcat $(SNMP_SOURCE) | tar -xvf -
#	cat $(SNMP_PATCH2) | patch -d $(SNMP_DIR) -p0
	cat $(SNMP_PATCH3) | patch -d $(SNMP_DIR) -p1
#	cat $(SNMP_PATCH4) | patch -d $(SNMP_DIR) -p1
#	cat $(SNMP_PATCH5) | patch -d $(SNMP_DIR) -p1
	perl -i -p -e 's,\$$CPP\s+\$$PARTIALTARGETFLAGS,\$$CPP \$$CFLAGS,' $(SNMP_DIR)/configure
	touch $@

source: $(SNMP_DIR)/.source

$(SNMP_DIR)/.configured: $(SNMP_DIR)/.source
	(cd $(SNMP_DIR) ; \
	 ./configure --prefix=/usr --sysconfdir=/etc --host=$(GNU_TARGET_NAME) \
		--enable-fast-install \
		--with-install-prefix="$(SNMP_TARGET_DIR)" \
		--with-cflags="$(CFLAGS)" \
		--with-ldflags="$(LDFLAGS)" \
		--with-defaults \
		--with-persistent-directory=/var/lib/snmp \
		--disable-scripts \
		--disable-manuals \
		--disable-embedded-perl \
		--enable-shared \
		--enable-ipv6 --with-logfile=none \
		--without-rpm --with-libwrap --with-openssl=internal \
		--without-dmalloc --without-efence --without-rsaref \
		--with-sys-contact="root" --with-sys-location="Unknown" \
		--with-mib-modules="$(MIB_MODULES)" \
		--without-perl-modules \
		)
	touch $(SNMP_DIR)/.configured

#	  	--enable-ucd-snmp-compatability \

$(SNMP_DIR)/.build: $(SNMP_DIR)/.configured
	mkdir -p $(SNMP_TARGET_DIR)
	mkdir -p $(SNMP_TARGET_DIR)/var/lib/snmp
	mkdir -p $(SNMP_TARGET_DIR)/etc/init.d
	mkdir -p $(SNMP_TARGET_DIR)/etc/default
	mkdir -p $(SNMP_TARGET_DIR)/etc/snmp
	$(MAKE) $(MAKEOPTS) -C $(SNMP_DIR)
	$(MAKE) -C $(SNMP_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(SNMP_TARGET_DIR)"/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) "$(SNMP_TARGET_DIR)"/usr/lib/*.so.*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," "$(SNMP_TARGET_DIR)"/usr/lib/*.la
	cp -aL snmptrapd.init "$(SNMP_TARGET_DIR)"/etc/init.d/snmptrapd
	cp -aL snmptrapd.default "$(SNMP_TARGET_DIR)"/etc/default/snmptrapd
	cp -aL snmptrapd.conf "$(SNMP_TARGET_DIR)"/etc/snmp/snmptrapd.conf
	cp -aL snmpd.init "$(SNMP_TARGET_DIR)"/etc/init.d/snmpd
	cp -aL snmpd.default "$(SNMP_TARGET_DIR)"/etc/default/snmpd
	cp -aL snmpd.conf "$(SNMP_TARGET_DIR)"/etc/snmp/snmpd.conf
	cp -a  "$(SNMP_TARGET_DIR)"/* "$(BT_STAGING_DIR)"
	touch $(SNMP_DIR)/.build

build: $(SNMP_DIR)/.build

clean:
	-$(MAKE) -C $(SNMP_DIR) distclean
	rm $(SNMP_DIR)/.build
	rm $(SNMP_DIR)/.configured
	rm -rf "$(SNMP_TARGET_DIR)"

srcclean: clean
	rm -rf $(SNMP_DIR)
