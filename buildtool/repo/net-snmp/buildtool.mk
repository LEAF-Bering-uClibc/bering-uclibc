#############################################################
#
# net-snmp
#
# $Id: buildtool.mk,v 1.4 2010/07/22 19:14:00 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

SNMP_DIR:=net-snmp-5.4.3
SNMP_TARGET_DIR:=$(BT_BUILD_DIR)/net-snmp

CFLAGS = $(BT_COPT_FLAGS) -D_REENTRANT
MIB_MODULES = host smux ucd-snmp/dlmod ucd-snmp/lmsensorsMib #ucd-snmp/lmSensors
PERLVER=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5 2>/dev/null)

$(SNMP_DIR)/.source:
	zcat $(SNMP_SOURCE) | tar -xvf -
#	cat $(SNMP_PATCH1) | patch -d $(SNMP_DIR) -p0
	cat $(SNMP_PATCH2) | patch -d $(SNMP_DIR) -p0
	cat $(SNMP_PATCH3) | patch -d $(SNMP_DIR) -p1
	cat $(SNMP_PATCH4) | patch -d $(SNMP_DIR) -p1
	cat $(SNMP_PATCH5) | patch -d $(SNMP_DIR) -p1
	touch $(SNMP_DIR)/.source

source: $(SNMP_DIR)/.source

$(SNMP_DIR)/.configured: $(SNMP_DIR)/.source
#echo timestamp >stamp-h.in
	cp "$(BT_STAGING_DIR)"/share/libtool/config/ltmain.sh $(SNMP_DIR)
	([ -$(PERLVER) = - ] || export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER); \
	cd $(SNMP_DIR); autoreconf -f)
	sed '/\(rpath\|finish\)/s/\$$(libdir)/\$$(BT_STAGING_DIR)\$$(libdir)/' $(SNMP_DIR)/Makefile.top >$(SNMP_DIR)/Makefile.tmp \
		&& mv $(SNMP_DIR)/Makefile.tmp $(SNMP_DIR)/Makefile.top
	(cd $(SNMP_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-fast-install \
		--with-install-prefix="$(SNMP_TARGET_DIR)/usr" \
		--with-persistent-directory=/var/lib/snmp \
		--disable-scripts \
		--disable-manuals \
		--disable-embedded-perl \
		--enable-shared --with-cflags="$(CFLAGS)" \
		--with-ldflags="-L$(SNMP_TARGET_DIR)/usr/lib" \
		--enable-ipv6 --with-logfile=none \
		--without-rpm --with-libwrap --without-openssl \
		--without-dmalloc --without-efence --without-rsaref \
		--with-sys-contact="root" --with-sys-location="Unknown" \
		--with-mib-modules="$(MIB_MODULES)" \
		--without-perl-modules \
		--with-defaults)
#	sed '/sys_lib_dlsearch_path_spec=/s/".*$$/\$$sys_lib_search_path_spec/' $(SNMP_DIR)/libtool >$(SNMP_DIR)/libtool.tmp \
#		&& mv $(SNMP_DIR)/libtool.tmp $(SNMP_DIR)/libtool
	touch $(SNMP_DIR)/.configured

#	  	--enable-ucd-snmp-compatability \

$(SNMP_DIR)/.build: $(SNMP_DIR)/.configured
	mkdir -p $(SNMP_TARGET_DIR)
	mkdir -p $(SNMP_TARGET_DIR)/var/lib/snmp
	mkdir -p $(SNMP_TARGET_DIR)/etc/init.d
	mkdir -p $(SNMP_TARGET_DIR)/etc/default
	mkdir -p $(SNMP_TARGET_DIR)/etc/snmp
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(SNMP_DIR)
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(SNMP_DIR) BT_STAGING_DIR="$(BT_STAGING_DIR)" \
		 INSTALL_PREFIX="$(SNMP_TARGET_DIR)" install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(SNMP_TARGET_DIR)"/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) "$(SNMP_TARGET_DIR)"/usr/lib/*.so.*
	(BTSD=`echo $(BT_STAGING_DIR)|sed 's/\//\\\\\//g'`;\
		for i in `ls $(SNMP_TARGET_DIR)/usr/lib/*.la`; do \
		sed 's/'$$BTSD'//g' $$i >$$i.tmp \
		&& mv $$i.tmp $$i; done)
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
