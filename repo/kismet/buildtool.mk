#############################################################
#
# kismet
#
#############################################################

include $(MASTERMAKEFILE)

KISMET_DIR:=kismet-2010-07-R1
KISMET_TARGET_DIR:=$(BT_BUILD_DIR)/kismet

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
#   But keep config files in /etc (rather than /usr/etc)
#   And keep state files in /var (rather than /usr/var)
CONFOPTS:=--prefix=/usr --sysconfdir=/etc --localstatedir=/var --host=$(GNU_TARGET_NAME)

# Next line is required to locate the .pc file for libnl
export PKG_CONFIG_PATH=$(BT_STAGING_DIR)/usr/lib/pkgconfig

$(KISMET_DIR)/.source:
	zcat $(KISMET_SOURCE) | tar -xvf -
	# Change hard-coded setting of CPPFLAGS for ncurses' panel.h
	( cd $(KISMET_DIR) ; perl -i -p -e "s,-I/usr/include/ncurses,-I$(BT_STAGING_DIR)/usr/include," configure )
	# Prevent attempt to run chmod (as non-root user) at "make install" time
	( cd $(KISMET_DIR) ; perl -i -p -e "s,-m [0-9]*,," Makefile.in )
	touch $(KISMET_DIR)/.source

$(KISMET_DIR)/.configure: $(KISMET_DIR)/.source
	( cd $(KISMET_DIR); libtoolize -i -f && autoreconf -i -f && \
	./configure $(CONFOPTS) );
	touch $(KISMET_DIR)/.configure

source: $(KISMET_DIR)/.source


$(KISMET_DIR)/.build: $(KISMET_DIR)/.configure
	mkdir -p $(KISMET_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(KISMET_DIR) dep
	$(MAKE) $(MAKEOPTS) -C $(KISMET_DIR) all
	# "rpm" target is a wrapper for "install" target, and better for LEAF
	$(MAKE) INSTUSR=`id -u` INSTGRP=`id -g` MANGRP=`id -g` DESTDIR=$(KISMET_TARGET_DIR) -C $(KISMET_DIR) rpm
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(KISMET_TARGET_DIR)/usr/bin/*
	# Patch generated configuration files
	(cd $(KISMET_TARGET_DIR)/etc ; patch < $(BT_SOURCE_DIR)/kismet/$(KISMET_PATCH1) )
	(cd $(KISMET_TARGET_DIR)/etc ; patch < $(BT_SOURCE_DIR)/kismet/$(KISMET_PATCH2) )
	-rm -rf $(KISMET_TARGET_DIR)/usr/share/man
	cp -ra $(KISMET_TARGET_DIR)/* $(BT_STAGING_DIR)
	cp -aL $(KISMET_MANUF) $(BT_STAGING_DIR)/etc
	touch $(KISMET_DIR)/.build

build: $(KISMET_DIR)/.build

clean:
	-rm $(KISMET_DIR)/.build
	rm -rf $(KISMET_TARGET_DIR)
	$(MAKE) -C $(KISMET_DIR) clean

srcclean:
	rm -rf $(KISMET_DIR)

