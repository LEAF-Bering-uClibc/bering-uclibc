#############################################################
#
# dhcpcd
#
#############################################################


DHCPCD_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(DHCPCD_SOURCE) 2>/dev/null )
DHCPCD_TARGET_DIR:=$(BT_BUILD_DIR)/dhcpcd

# Option settings for 'configure':
CONFOPTS:= --host=$(GNU_TARGET_NAME) --prefix=/ --build=$(GNU_BUILD_NAME)

$(DHCPCD_DIR)/.source:
	bzcat $(DHCPCD_SOURCE) | tar -xvf -
	cat $(DHCPCD_PATCH1) | patch -d $(DHCPCD_DIR) -p1
	touch $(DHCPCD_DIR)/.source

source: $(DHCPCD_DIR)/.source

$(DHCPCD_DIR)/.configure: $(DHCPCD_DIR)/.source
	( cd $(DHCPCD_DIR) ; ./configure $(CONFOPTS) )
	touch $(DHCPCD_DIR)/.configure

$(DHCPCD_DIR)/.build: $(DHCPCD_DIR)/.configure
	mkdir -p $(DHCPCD_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/
	mkdir -p $(BT_STAGING_DIR)/libexec/dhcpcd-hooks
	make $(MAKEOPTS) -C $(DHCPCD_DIR)
	make -C $(DHCPCD_DIR) DESTDIR=$(DHCPCD_TARGET_DIR) BINMODE=0755 NONBINMODE=0644 install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DHCPCD_TARGET_DIR)/sbin/*

	rm -rf $(DHCPCD_TARGET_DIR)/share
	cp -aL dhcpcd.conf $(DHCPCD_TARGET_DIR)/etc/
	cp -aL resolv.conf.head $(DHCPCD_TARGET_DIR)/etc/
	cp -aL resolv.conf.tail $(BT_STAGING_DIR)/etc/
	cp -a $(DHCPCD_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DHCPCD_DIR)/.build

build: $(DHCPCD_DIR)/.build

clean:
	-rm -rf $(DHCPCD_TARGET_DIR)
	-rm -f $(DHCPCD_DIR)/.build
	-rm -f $(DHCPCD_DIR)/.configure

srcclean: clean
	-rm -rf $(DHCPCD_DIR)
