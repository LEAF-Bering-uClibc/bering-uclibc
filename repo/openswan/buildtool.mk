
OPENSWAN_DIR:=$(OPENSWAN_SOURCE:.tar.gz=)
OPENSWAN_TARGET_DIR:=$(BT_BUILD_DIR)/openswan

export USE_AGGRESSIVE=false
export USE_XAUTH=true
export USE_BASH=false
export USE_EXTRACRYPTO=true


.source:
	zcat $(OPENSWAN_SOURCE) | tar -xvf -
	echo $(OPENSWAN_DIR) > .source

source: .source

.build: .source
	-rm -rf $(OPENSWAN_TARGET_DIR)
	mkdir -p $(OPENSWAN_TARGET_DIR)
	mkdir -p $(OPENSWAN_TARGET_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/usr/sbin

	############################################################
	## build the userland programs
	############################################################
	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) -C $(OPENSWAN_DIR) programs \
	    INC_USRLOCAL="/usr" \
	    FINALBINDIR="/usr/lib/ipsec" \
	    FINALLIBEXECDIR="/usr/lib/ipsec" \
	    KERNELSRC=$(BT_LINUX_DIR) \
	    DESTDIR=$(OPENSWAN_TARGET_DIR) \
	    WERROR=" "

	############################################################
	## install the userland programs
	############################################################
	$(MAKE) CC=$(TARGET_CC) -C $(OPENSWAN_DIR) install \
	    INC_USRLOCAL="/usr" \
	    FINALBINDIR="/usr/lib/ipsec" \
	    FINALLIBEXECDIR="/usr/lib/ipsec" \
	    KERNELSRC=$(BT_LINUX_DIR) \
	    DESTDIR=$(OPENSWAN_TARGET_DIR) \
	    WERROR=" "

	############################################################
	## build a KLIPS module for all supported platforms
	############################################################
	for i in $(KARCHS); do \
	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) -C $(OPENSWAN_DIR) module\
	    LDFLAGS="" \
	    INC_USRLOCAL="/usr" \
	    FINALBINDIR="/usr/lib/ipsec" \
	    FINALLIBEXECDIR="/usr/lib/ipsec" \
	    KERNELSRC=$(BT_LINUX_DIR)-$$i \
	    DESTDIR=$(OPENSWAN_TARGET_DIR) && \
	    mkdir -p $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/net/ipsec &&\
	    gzip -9 $(OPENSWAN_DIR)/modobj26/ipsec.ko &&\
	    mv -f $(OPENSWAN_DIR)/modobj26/ipsec.ko.gz $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/net/ipsec &&\
	    $(MAKE) CC=$(TARGET_CC) -C $(OPENSWAN_DIR) modclean || exit 1 ;\
	done;

	cp -fL ipsec.secrets $(OPENSWAN_TARGET_DIR)/etc/
	cp -fL ipsec.init $(OPENSWAN_TARGET_DIR)/etc/init.d/ipsec
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSWAN_TARGET_DIR)/usr/lib/ipsec/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSWAN_TARGET_DIR)/usr/sbin/*
	-rm -rf $(OPENSWAN_TARGET_DIR)/usr/man
	-rm -rf $(OPENSWAN_TARGET_DIR)/usr/share
	cp -a $(OPENSWAN_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch .build

build: .build

clean:
	-rm -f .build
	rm -rf $(OPENSWAN_TARGET_DIR)
	for i in $(KARCHS); do \
	    rm -rf $(BT_STAGING_DIR)/lib/modules/$(BT_KERNEL_RELEASE)-$$i/kernel/net/ipsec ;\
	done;
	make -C `cat .source` clean

srcclean: clean
	rm -rf `cat .source`
	rm .source

#
# $Log: buildtool.mk,v $
# Revision 1.5  2010/12/27 09:57:56  etitl
# remove copy of ipsec to /etc/init.d
#
# Revision 1.4  2010/12/23 17:13:01  etitl
# Copy template files to /etc/ipsec.d and touch the .build flag
#
# Revision 1.3  2010/12/23 17:10:30  etitl
# We can fetch the include files and libs from the staging directory, no need
# for the build dir.
#
# Revision 1.2  2010/12/23 14:47:46  etitl
# Use libgmp from buildenv, this may make the libgmp package redundant
#
#
