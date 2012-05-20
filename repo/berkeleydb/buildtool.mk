#############################################################
#
# buildtool makefile for berkeleydb 
#
#############################################################

include $(MASTERMAKEFILE)

SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
ifeq ($(SOURCE_DIR),)
SOURCE_DIR:=$(shell cat DIRNAME)
endif
TARGET_DIR:=$(BT_BUILD_DIR)/berkeleydb

# Variable definitions for 'configure'
#  Yes, we have a working avahi client library
CONFDEFS = ac_cv_lib_avahi_client_avahi_client_new=yes

# Option settings for 'configure'
#  Specify location of sysroot
#  Move files out from under /usr/local
#  Make "small footprint" version of the library
CONFOPTS = \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-sysroot=$(BT_STAGING_DIR) \
	--prefix=/usr \
	--enable-smallbuild

.source:
	zcat $(SOURCE_TGZ) | tar -xvf -
	echo $(SOURCE_DIR) > DIRNAME
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR)/build_unix ; $(CONFDEFS) ../dist/configure $(CONFOPTS) )
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include

	( cd $(SOURCE_DIR)/build_unix ; make )
	# Don't need to install docs ("install_docs") which is part of "install"
	( cd $(SOURCE_DIR)/build_unix ; make DESTDIR=$(TARGET_DIR) install_lib )
	( cd $(SOURCE_DIR)/build_unix ; make DESTDIR=$(TARGET_DIR) install_include )
	( cd $(SOURCE_DIR)/build_unix ; make DESTDIR=$(TARGET_DIR) install_utilities )
	# Fix permissions
	chmod -R u+w $(TARGET_DIR)

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.a
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
	cp -a $(TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/usr/lib/*.a $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/lib/*.so* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	touch .build	

clean:
	-make -C $(SOURCE_DIR) clean
	rm -rf $(TARGET_DIR)
	rm -f .build
	rm -f .configured
	
srcclean:
	rm -rf $(SOURCE_DIR)
	rm .source
	rm DIRNAME
