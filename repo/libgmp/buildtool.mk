#############################################################
#
# libgmp
#
#############################################################

#LIBGMP_DIR:=gmp-5.0.5
LIBGMP_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBGMP_SOURCE) 2>/dev/null)
LIBGMP_TARGET_DIR:=$(BT_BUILD_DIR)/libgmp

$(LIBGMP_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBGMP_SOURCE)
#	bzcat $(LIBGMP_SOURCE) |  tar -xvf -
	touch $(LIBGMP_DIR)/.source


$(LIBGMP_DIR)/.configured: $(LIBGMP_DIR)/.source
	(cd $(LIBGMP_DIR); ./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr);
	touch $(LIBGMP_DIR)/.configured

source: $(LIBGMP_DIR)/.source

$(LIBGMP_DIR)/.build: $(LIBGMP_DIR)/.configured
	mkdir -p $(LIBGMP_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	$(MAKE) $(MAKEOPTS) -C $(LIBGMP_DIR)
	$(MAKE) DESTDIR=$(LIBGMP_TARGET_DIR) -C $(LIBGMP_DIR) install
	-$(BT_STRIP) $(BTSTRIP_LIBOPTS) $(LIBGMP_TARGET_DIR)/usr/lib
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBGMP_TARGET_DIR)/usr/lib/*.la
	-rm -rf $(LIBGMP_TARGET_DIR)/usr/share
	cp -a $(LIBGMP_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(LIBGMP_DIR)/.build

build: $(LIBGMP_DIR)/.build

clean:
	-rm $(LIBGMP_DIR)/.build
	rm -rf $(LIBGMP_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libgmp.*
	rm -f $(BT_STAGING_DIR)/usr/lib/libmp.*
	rm -f $(BT_STAGING_DIR)/usr/include/gmp.h
	rm -f $(BT_STAGING_DIR)/usr/include/mp.h
	$(MAKE) -C $(LIBGMP_DIR) clean

srcclean: clean
	rm -rf $(LIBGMP_DIR)

