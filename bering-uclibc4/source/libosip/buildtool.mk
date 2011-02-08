#############################################################
#
# libosip2
#
# $Id: buildtool.mk,v 1.2 2006/12/12 21:11:28 espakman Exp $
#############################################################

include $(MASTERMAKEFILE)
LIBOSIP2_DIR=libosip2-2.2.2
LIBOSIP2_TARGET_DIR=$(BT_BUILD_DIR)/libosip

$(LIBOSIP2_DIR)/.source: 
	zcat $(LIBOSIP2_SOURCE) | tar -xvf -
	touch $(LIBOSIP2_DIR)/.source

$(LIBOSIP2_DIR)/.configured: $(LIBOSIP2_DIR)/.source 
	(cd $(LIBOSIP2_DIR) ; autoconf ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure --host=$(GNU_HOST_NAME) --build=$(GNU_HOST_NAME) --prefix=/usr --disable-shared );
	touch $(LIBOSIP2_DIR)/.configured

$(LIBOSIP2_DIR)/.build: $(LIBOSIP2_DIR)/.configured
	mkdir -p $(LIBOSIP2_TARGET_DIR)
	mkdir -p $(LIBOSIP2_TARGET_DIR)/usr/lib
	$(MAKE) -C $(LIBOSIP2_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)"
	$(MAKE) -C $(LIBOSIP2_DIR) DESTDIR=$(LIBOSIP2_TARGET_DIR) install-data
	cp $(LIBOSIP2_DIR)/src/osip2/.libs/libosip2.a $(LIBOSIP2_TARGET_DIR)/usr/lib/
	cp $(LIBOSIP2_DIR)/src/osipparser2/.libs/libosipparser2.a $(LIBOSIP2_TARGET_DIR)/usr/lib/
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBOSIP2_TARGET_DIR)/usr/lib/libosip2.a
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBOSIP2_TARGET_DIR)/usr/lib/libosipparser2.a
	cp -a $(LIBOSIP2_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBOSIP2_DIR)/.build

source: $(LIBOSIP2_DIR)/.source

build: $(LIBOSIP2_DIR)/.build

clean:         
	make -C $(LIBOSIP2_DIR) clean
	rm $(LIBOSIP2_TARGET_DIR)/.build
	rm -rf $(LIBOSIP2_TARGET_DIR)

srcclean:
	rm -rf $(LIBOSIP2_DIR)	
