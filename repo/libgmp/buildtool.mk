#############################################################
#
# $Id:
#
#############################################################

include $(MASTERMAKEFILE)
LIBGMP_DIR:=gmp-5.0.1
LIBGMP_TARGET_DIR:=$(BT_BUILD_DIR)/libgmp
export CC=$(TARGET_CC)
CNFL=--enable-mpbsd
CFCT="-Os "
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment

$(LIBGMP_DIR)/.source:
	bzcat $(LIBGMP_SOURCE) |  tar -xvf -
	#zcat $(LIBGMP_PATCH1) |  patch -d $(LIBGMP_DIR) -p1
	touch $(LIBGMP_DIR)/.source


$(LIBGMP_DIR)/.configured: $(LIBGMP_DIR)/.source
	(cd $(LIBGMP_DIR); ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --prefix=/usr $(CNFL));
	touch $(LIBGMP_DIR)/.configured

#source: $(LIBGMP_DIR)/.source
source:

$(LIBGMP_DIR)/.build: $(LIBGMP_DIR)/.configured
	mkdir -p $(LIBGMP_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	$(MAKE) CFLAGS=$(CFCT) -C $(LIBGMP_DIR)
	$(MAKE) CFLAGS=$(CFCT) DESTDIR=$(LIBGMP_TARGET_DIR) -C $(LIBGMP_DIR) install
	cp -a $(LIBGMP_TARGET_DIR)/usr/lib/libgmp.* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(LIBGMP_TARGET_DIR)/usr/lib/libmp.* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(LIBGMP_TARGET_DIR)/usr/include/gmp.h $(BT_STAGING_DIR)/usr/include
	cp -a $(LIBGMP_TARGET_DIR)/usr/include/mp.h $(BT_STAGING_DIR)/usr/include
	touch $(LIBGMP_DIR)/.build

build:
#build: $(LIBGMP_DIR)/.build

clean:
	-rm $(LIBGMP_DIR)/.build
	rm -rf $(LIBGMP_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libgmp.*
	rm -f $(BT_STAGING_DIR)/usr/lib/libmp.*
	rm -f $(BT_STAGING_DIR)/usr/include/gmp.h
	rm -f $(BT_STAGING_DIR)/usr/include/mp.h
	$(MAKE) -C $(LIBGMP_DIR) clean

srcclean:
	rm -rf $(LIBGMP_DIR)

