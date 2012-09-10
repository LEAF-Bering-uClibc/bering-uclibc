######################################
#
# buildtool makefile for Shorewall (core) Firewall
#
######################################

include $(MASTERMAKEFILE)

TARGET_DIR=$(BT_BUILD_DIR)/shorewall-core

SHOREWALL-CORE_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(SHOREWALL-CORE_SOURCE) 2>/dev/null )

$(SHOREWALL-CORE_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SHOREWALL-CORE_SOURCE)
	touch $(SHOREWALL-CORE_DIR)/.source

#errata

$(SHOREWALL-CORE_DIR)/.configured: $(SHOREWALL-CORE_DIR)/.source
	( cd $(SHOREWALL-CORE_DIR); ./configure \
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
	--sysconfdir=/etc/default )
	touch $(SHOREWALL-CORE_DIR)/.configured

$(SHOREWALL-CORE_DIR)/.build: $(SHOREWALL-CORE_DIR)/.configured
	mkdir -p $(TARGET_DIR)
	(cd $(SHOREWALL-CORE_DIR); env PREFIX=$(TARGET_DIR) DESTDIR=$(TARGET_DIR) ./install.sh)
	
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SHOREWALL-CORE_DIR)/.build

source: $(SHOREWALL-CORE_DIR)/.source

build:  $(SHOREWALL-CORE_DIR)/.build                                                                                                   
	cp -afv $(TARGET_DIR)/* $(BT_STAGING_DIR)

clean:	stageclean
	rm -rf $(TARGET_DIR)
	rm -f  $(SHOREWALL-CORE_DIR)/.build
	rm -f  $(SHOREWALL-CORE_DIR)/.configured

stageclean:
	rm -rf $(BT_STAGING_DIR)/usr/share/shorewall

srcclean: clean
	rm -rf $(SHOREWALL-CORE_DIR)
