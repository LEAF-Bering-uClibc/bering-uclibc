#############################################################
#
# buildtool makefile for libiconv
#
#############################################################

include $(MASTERMAKEFILE)

SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
ifeq ($(SOURCE_DIR),)
SOURCE_DIR:=$(shell cat DIRNAME)
endif
TARGET_DIR:=$(BT_BUILD_DIR)/libiconv

# Option settings for 'configure'
#   Move default install from /usr/local/ to /usr/
CONFOPTS = --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) \
	--prefix=/usr

.source:
	zcat $(SOURCE_TGZ) | tar -xvf -
	echo $(SOURCE_DIR) > DIRNAME
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR) ; ./configure $(CONFOPTS) )
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib/
	mkdir -p $(BT_STAGING_DIR)/usr/include/

	make -C $(SOURCE_DIR)
	make -C $(SOURCE_DIR) DESTDIR=$(TARGET_DIR) install

	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(TARGET_DIR)/usr/lib/*.la
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	touch .build	

clean:
	-make -C $(SOURCE_DIR)/source3 clean
	rm -rf $(TARGET_DIR)
	rm -f .build
	rm -f .configured
	
srcclean:
	rm -rf $(SOURCE_DIR)
	rm .source
	rm DIRNAME
