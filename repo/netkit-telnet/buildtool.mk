#############################################################
#
# copied from syslinux example
#
#############################################################

include $(MASTERMAKEFILE)
TELNET_DIR:=netkit-telnet-0.17
TELNET_TARGET_DIR:=$(BT_BUILD_DIR)/netkit-telnet
export CFLAGS += $(LDFLAGS)
export CXXFLAGS = $(CPPFLAGS) $(LDFLAGS)

$(TELNET_DIR)/.source:
	zcat $(TELNET_SOURCE) |  tar -xvf -
	zcat $(TELNET_PATCH1) | patch -d $(TELNET_DIR) -p1
	perl -i -p -e 's,-I/usr,-I$(BT_STAGING_DIR)/usr,g' $(TELNET_DIR)/configure
	perl -i -p -e 's,LDFLAGS=\s*$$,,g' $(TELNET_DIR)/configure
	touch $(TELNET_DIR)/.source

source: $(TELNET_DIR)/.source

$(TELNET_DIR)/.configured: $(TELNET_DIR)/.source
	(cd $(TELNET_DIR); ./configure \
	--with-c-compiler=$(TARGET_CC) \
	--with-c++-compiler=$(TARGET_CXX))
	touch $(TELNET_DIR)/.configured

$(TELNET_DIR)/.build: $(TELNET_DIR)/.configured
	export LANG=en_US  # Hack for Redhat 9
	mkdir -p $(TELNET_TARGET_DIR)
	mkdir -p $(TELNET_TARGET_DIR)/usr/bin
	$(MAKE) $(MAKEOPTS) -C $(TELNET_DIR) SUB=telnet
	cp -a $(TELNET_DIR)/telnet/telnet $(TELNET_TARGET_DIR)/usr/bin/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TELNET_TARGET_DIR)/usr/bin/*
	cp -a $(TELNET_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TELNET_DIR)/.build

build: $(TELNET_DIR)/.build

clean:
	$(MAKE) -C $(TELNET_DIR) clean
	rm -rf $(TELNET_TARGET_DIR)
	rm -rf $(TELNET_DIR)/.build
	rm -rf $(TELNET_DIR)/.configured

srcclean: clean
	rm -rf $(TELNET_DIR)
