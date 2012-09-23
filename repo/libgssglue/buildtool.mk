#############################################################
#
# buildtool makefile for libgssglue
#
#############################################################


SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/libgssglue

# Option settings for 'configure'
CONFOPTS = \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr

.source:
	zcat $(SOURCE_TGZ) | tar -xvf -
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR) ; ./configure $(CONFOPTS) )
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)/etc
	mkdir -p $(BT_STAGING_DIR)/etc
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include

	make -C $(SOURCE_DIR)
	make -C $(SOURCE_DIR) DESTDIR=$(TARGET_DIR) install
	cp $(SOURCE_DIR)/doc/gssapi_mech.conf $(TARGET_DIR)/etc/

	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	cp -a $(TARGET_DIR)/etc/* $(BT_STAGING_DIR)/etc/
	touch .build	

clean:
	-make -C $(SOURCE_DIR) clean
	rm -rf $(TARGET_DIR)
	rm -f .build
	rm -f .configured
	
srcclean:
	rm -rf $(SOURCE_DIR)
	rm .source
