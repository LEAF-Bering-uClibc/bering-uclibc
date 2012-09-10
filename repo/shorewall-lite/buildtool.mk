######################################
#
# buildtool makefile for Shoreline Firewall (lite)
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall-lite

SHOREWALL_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(SHOREWALL_SOURCE) 2>/dev/null )

$(SHOREWALL_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SHOREWALL_SOURCE)
	touch $(SHOREWALL_DIR)/.source

$(SHOREWALL_DIR)/.configured: $(SHOREWALL_DIR)/.source
	( cd $(SHOREWALL_DIR); ./configure \
	--host=linux \
	--build=linux \
	--prefix=/usr \
	--sharedir=/usr/share \
	--libexecdir=/usr/share \
	--perllibdir=/usr/share/shorewall \
	--confdir=/etc \
	--sbindir=/sbin \
	--initdir=/etc/init.d \
	--initfile=shorewall \
	--initsource=init.sh \
	--annotated= \
	--vardir=/var/lib \
	--sysconfdir=/etc/shorewall )
	touch $(SHOREWALL_DIR)/.configured



$(SHOREWALL_DIR)/.build: $(SHOREWALL_DIR)/.configured
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL_DIR); DESTDIR=$(TARGET_DIR) ./install.sh)

	mkdir -p $(TARGET_DIR)/etc/default
	install -c $(SHOREWALL_DEFAULT) $(TARGET_DIR)/etc/default/shorewall-lite
	rm -f $(TARGET_DIR)/etc/init.d/shorewall-lite
	mkdir -p $(TARGET_DIR)/etc/init.d
	cp $(SHOREWALL_INIT) $(TARGET_DIR)/etc/init.d/shorewall-lite

	rm -rf $(TARGET_DIR)/etc/shorewall/Makefile
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SHOREWALL_DIR)/.build

source: $(SHOREWALL_DIR)/.source

build:  $(SHOREWALL_DIR)/.build
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL_DIR)/.build
	rm -f  $(SHOREWALL_DIR)/.configured

stageclean:
	rm -f  $(BT_STAGING_DIR)/etc/init.d/shorewall-lite
	rm -f  $(BT_STAGING_DIR)/etc/default/shorewall-lite

srcclean: clean
	rm -rf $(SHOREWALL_DIR)
