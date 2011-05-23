#############################################################
#
# zlib
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:31 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

ZLIB_DIR=zlib-1.2.5
ZLIB_BUILD_DIR=$(BT_BUILD_DIR)/zlib

ZLIB_CFLAGS="-Os -g -fPIC"


$(ZLIB_DIR)/.source: 
	zcat $(ZLIB_SOURCE) | tar -xvf -
	touch $(ZLIB_DIR)/.source
	
$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.source
	(cd $(ZLIB_DIR); CFLAGS=$(ZLIB_CFLAGS);  \
		./configure --shared \
		--prefix=/usr );
	touch $(ZLIB_DIR)/.configured


$(ZLIB_DIR)/.build: $(ZLIB_DIR)/.configured
	make LDSHARED="$(TARGET_CC) --shared" CFLAGS=$(ZLIB_CFLAGS) CC=$(TARGET_CC) -C $(ZLIB_DIR) all libz.a;
	mkdir -p $(ZLIB_BUILD_DIR)/usr
	make -C $(ZLIB_DIR) install prefix=$(ZLIB_BUILD_DIR)/usr
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ZLIB_BUILD_DIR)/usr/lib/libz.so.*
	cp -a $(ZLIB_BUILD_DIR)/* $(BT_STAGING_DIR)
	touch $(ZLIB_DIR)/.build


source: $(ZLIB_DIR)/.source

build: $(ZLIB_DIR)/.build

clean:  
	-rm $(ZLIB_DIR)/.build
	-make -C $(ZLIB_DIR) clean

srcclean:
	rm -rf $(ZLIB_DIR)	
