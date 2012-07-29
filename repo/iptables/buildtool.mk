#############################################################
#
# iptables
#
# $Id: buildtool.mk,v 1.8 2010/12/08 18:28:44 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
IPTABLES_VER=1.4.12.2
IPTABLES_DIR:=iptables-$(IPTABLES_VER)
IPT_NF_DIR:=ipt_netflow-1.7.1
IPTABLES_TARGET_DIR:=$(BT_BUILD_DIR)/iptables

EXTRA_VARS := BINDIR=/sbin \
	DO_IPV6=1 \
	PREFIX= \
	KERNEL_DIR=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE) \
	COPT_FLAGS="$(CFLAGS)" \
	LIBDIR=/lib \
	MANDIR=/usr/share/man \
	INCDIR=/usr/include \
	DESTDIR=$(IPTABLES_TARGET_DIR)

BUILD_TARGETS :=all
#iptables-save iptables-restore ip6tables-save ip6tables-restore

$(IPTABLES_DIR)/.source:
	bzcat $(IPTABLES_SOURCE) |  tar -xvf -
	cat $(IPTABLES_PATCH1) | patch -d $(IPTABLES_DIR) -p1
	cat $(IPTABLES_PATCH2) | patch -d $(IPTABLES_DIR)/extensions -p0
	touch $(IPTABLES_DIR)/.source

$(IPT_NF_DIR)/.source:
	zcat $(IPT_NF_SOURCE) |  tar -xvf -
	perl -i -p -e 's/gcc/\$$(CC)/' $(IPT_NF_DIR)/Makefile.in
	touch $(IPT_NF_DIR)/.source

$(IPTABLES_DIR)/Makefile: $(IPTABLES_DIR)/.source
	(cd $(IPTABLES_DIR); ./configure --prefix=/ \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--libexecdir=/lib --includedir=/usr/include \
	--with-kernel=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE) --enable-devel )

$(IPTABLES_DIR)/.build: $(IPTABLES_DIR)/Makefile
	-rm -rf $(IPTABLES_TARGET_DIR)
	mkdir -p $(IPTABLES_TARGET_DIR)
	mkdir -p $(IPTABLES_TARGET_DIR)/etc/default
	mkdir -p $(IPTABLES_TARGET_DIR)/etc/init.d
	mkdir -p $(IPTABLES_TARGET_DIR)/etc/iptables
	mkdir -p $(IPTABLES_TARGET_DIR)/usr/include/iptables
	mkdir -p $(IPTABLES_TARGET_DIR)/usr/include/net/netfilter
	mkdir -p $(IPTABLES_TARGET_DIR)/usr/lib
	$(MAKE) $(MAKEOPTS) -C $(IPTABLES_DIR) $(BUILD_TARGETS)
	$(MAKE) $(MAKEOPTS) -C $(IPTABLES_DIR) DESTDIR=$(IPTABLES_TARGET_DIR) install
	cp -a $(IPTABLES_DIR)/include/ip*.h $(IPTABLES_TARGET_DIR)/usr/include
	cp -a $(IPTABLES_DIR)/include/iptables/*.h $(IPTABLES_TARGET_DIR)/usr/include/iptables
	cp -a $(IPTABLES_DIR)/include/net/netfilter/*.h $(IPTABLES_TARGET_DIR)/usr/include/net/netfilter
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPTABLES_TARGET_DIR)/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(IPTABLES_TARGET_DIR)/lib/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(IPTABLES_TARGET_DIR)/lib/xtables/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/lib\'," $(IPTABLES_TARGET_DIR)/lib/*.la
	mv -f $(IPTABLES_TARGET_DIR)/lib/pkgconfig $(IPTABLES_TARGET_DIR)/usr/lib
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(IPTABLES_TARGET_DIR)/usr/lib/pkgconfig/*.pc
#	perl -i -p -e "s,=/lib,=$(BT_STAGING_DIR)/lib," $(IPTABLES_TARGET_DIR)/usr/lib/pkgconfig/*.pc
#	perl -i -p -e "s,prefix=/$$,prefix=$(BT_STAGING_DIR)," $(IPTABLES_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(IPTABLES_TARGET_DIR)/share
	cp -aL iptables.init $(IPTABLES_TARGET_DIR)/etc/init.d/iptables
	cp -aL iptables.init $(IPTABLES_TARGET_DIR)/etc/init.d/ip6tables
	cp -aL iptables-config $(IPTABLES_TARGET_DIR)/etc/iptables/iptables-config
	cp -aL iptables-config $(IPTABLES_TARGET_DIR)/etc/iptables/ip6tables-config
	touch $(IPTABLES_TARGET_DIR)/etc/iptables/iptables
	touch $(IPTABLES_TARGET_DIR)/etc/iptables/ip6tables
	touch $(IPTABLES_DIR)/.build

$(IPT_NF_DIR)/.build: $(IPT_NF_DIR)/configure $(IPTABLES_DIR)/.build
	mkdir -p $(IPTABLES_TARGET_DIR)/lib/xtables
	(cd $(IPT_NF_DIR) && for i in $(KARCHS); do  \
	./configure --kver=$(BT_KERNEL_RELEASE)-$$i \
	--kdir=$(BT_LINUX_DIR)-$$i \
	--ipt-ver=$(IPTABLES_VER) \
	--ipt-bin=$(IPTABLES_TARGET_DIR)/sbin/iptables \
	--ipt-lib=$(IPTABLES_TARGET_DIR)/lib/xtables \
	--ipt-inc=$(IPTABLES_TARGET_DIR)/usr/include &&\
	$(MAKE) clean && \
	$(MAKE) ipt_NETFLOW.ko && gzip -9 -f ipt_NETFLOW.ko && \
	mkdir -p $(IPTABLES_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/net/ipv4/netfilter && \
	cp -a ipt_NETFLOW.ko.gz $(IPTABLES_TARGET_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/net/ipv4/netfilter || \
	exit 1 ; done; \
	CC=$(TARGET_CC) $(MAKE) linstall)
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(IPTABLES_TARGET_DIR)/lib/xtables/*
	touch $(IPT_NF_DIR)/.build

source: $(IPTABLES_DIR)/.source $(IPT_NF_DIR)/.source

build: $(IPTABLES_DIR)/.build $(IPT_NF_DIR)/.build $(IPTABLES_TARGET_DIR)/sbin/iptables
	cp -a $(IPTABLES_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	-rm $(IPTABLES_DIR)/.build
	-rm iptables
	-$(MAKE) -C $(IPTABLES_DIR) clean

srcclean:
	rm -rf $(IPTABLES_DIR)
