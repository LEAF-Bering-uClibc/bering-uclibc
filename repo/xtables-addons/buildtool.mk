#############################################################
#
# iptables
#
# $Id: buildtool.mk,v 1.1 2010/11/09 21:18:08 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
DIR:=xtables-addons-1.40
TARGET_DIR:=$(BT_BUILD_DIR)/xtables-addons

#IPhash settings
#max sets
IP_NF_SET_MAX=256
#max items count in set
IP_NF_SET_HASHSIZE=4096

$(DIR)/.source:
	xzcat $(SOURCE) |  tar -xvf -
	perl -i -p -e 's,build_CHECKSUM=.*,build_CHECKSUM=m,;s,build_ipset6=.*,build_ipset6=,' $(DIR)/mconfig
	touch $(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(TARGET_DIR)
	(cd $(DIR) && for i in $(KARCHS); do export LOCALVERSION="-$$i" ; \
	export KERNEL_DIR=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE) ; \
	export KBUILD_OUTPUT=$(BT_LINUX_DIR)-$$i ; \
	./configure --host=$(GNU_TARGET_NAME) --prefix=/ \
	--with-kbuild=$$KERNEL_DIR --with-xtlibdir=/lib/xtables &&\
	$(MAKE) -C extensions clean && \
	$(MAKE) $(MAKEOPTS) -C extensions modules && \
	find extensions -name '*.ko' -exec $(BT_STRIP) $(BT_STRIP_LIBOPTS) {} + && \
	find extensions -name '*.ko' -exec gzip -9 -f {} + && \
	find extensions -name '*.ko' -exec mv {} $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/extra \; && \
	depmod -ae -b $(BT_STAGING_DIR) -F $(BT_BUILD_DIR)/kernel/System.map-$(BT_KERNEL_RELEASE)-$$i \
	$(BT_KERNEL_RELEASE)-$$i || exit 1 ; done; \
	$(MAKE) $(MAKEOPTS) -C extensions user-all-local && \
	$(MAKE) -C extensions DESTDIR=$(TARGET_DIR) user-install-local)
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/lib/xtables/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/sbin/*
	rm -rf $(TARGET_DIR)/usr/share
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

source: $(DIR)/.source 

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	-$(MAKE) -C $(DIR) clean
  
srcclean:
	rm -rf $(DIR)
