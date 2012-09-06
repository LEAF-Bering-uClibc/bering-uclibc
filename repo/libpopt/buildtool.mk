#############################################################
#
# libpcap
#
#############################################################

include $(MASTERMAKEFILE)

LIBPOPT_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBPOPT_SOURCE) 2>/dev/null )
LIBPOPT_TARGET_DIR:=$(BT_BUILD_DIR)/libpopt

$(LIBPOPT_DIR)/.source:
	zcat $(LIBPOPT_SOURCE) |  tar -xvf -
	touch $(LIBPOPT_DIR)/.source

$(LIBPOPT_DIR)/.configured: $(LIBPOPT_DIR)/.source
	(cd $(LIBPOPT_DIR); \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--prefix=/usr \
			--disable-nls \
			--disable-rpath );
	touch $(LIBPOPT_DIR)/.configured

source: $(LIBPOPT_DIR)/.source


$(LIBPOPT_DIR)/.build: $(LIBPOPT_DIR)/.configured
	mkdir -p $(LIBPOPT_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	$(MAKE) $(MAKEOPTS) -C $(LIBPOPT_DIR)
	$(MAKE) DESTDIR=$(LIBPOPT_TARGET_DIR) -C $(LIBPOPT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBPOPT_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBPOPT_TARGET_DIR)/usr/lib/*.la
	rm -rf $(LIBPOPT_TARGET_DIR)/usr/share
	cp -a -f $(LIBPOPT_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(LIBPOPT_DIR)/.build

build: $(LIBPOPT_DIR)/.build

clean:
	-rm $(LIBPOPT_DIR)/.build $(LIBPOPT_DIR)/.configured
	-rm -rf $(LIBPOPT_TARGET_DIR)
	$(MAKE) -C $(LIBPOPT_DIR) clean

srcclean:
	rm -rf $(LIBPOPT_DIR)
