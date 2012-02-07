#############################################################
#
# zlib
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:31 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

ZLIB_DIR=zlib-1.2.5
ZLIB_BUILD_DIR=$(BT_BUILD_DIR)/zlib

export CFLAGS += -g -fPIC


$(ZLIB_DIR)/.source:
	zcat $(ZLIB_SOURCE) | tar -xvf -
	touch $(ZLIB_DIR)/.source

$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.source
	(cd $(ZLIB_DIR); CHOST=$(GNU_TARGET_NAME) \
		./configure --shared \
		--prefix=/usr );
	touch $(ZLIB_DIR)/.configured


$(ZLIB_DIR)/.build: $(ZLIB_DIR)/.configured
	mkdir -p $(ZLIB_BUILD_DIR)/usr
	make $(MAKEOPTS) -C $(ZLIB_DIR) all libz.a;
	make -C $(ZLIB_DIR) install prefix=$(ZLIB_BUILD_DIR)/usr
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ZLIB_BUILD_DIR)/usr/lib/*
	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(ZLIB_BUILD_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(ZLIB_BUILD_DIR)/usr/share
	cp -a $(ZLIB_BUILD_DIR)/* $(BT_STAGING_DIR)
	touch $(ZLIB_DIR)/.build

source: $(ZLIB_DIR)/.source

build: $(ZLIB_DIR)/.build

clean:
	-rm $(ZLIB_DIR)/.build
	-make -C $(ZLIB_DIR) clean

srcclean:
	rm -rf $(ZLIB_DIR)
