#############################################################
#
# buildtool makefile for krb5
#
#############################################################

include $(MASTERMAKEFILE)

SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE_TGZ) 2>/dev/null )
ifeq ($(SOURCE_DIR),)
SOURCE_DIR:=$(shell cat DIRNAME)
endif
TARGET_DIR:=$(BT_BUILD_DIR)/krb5

# Variable definitions for 'configure'
CONFDEFS = krb5_cv_attr_constructor_destructor=yes,yes

# Option settings for 'configure'
CONFOPTS = --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME) \
	--prefix=/usr \
	--with-ldap \
	--enable-dns-for-realm

.source:
	zcat $(SOURCE_TGZ) | tar -xvf -
	echo $(SOURCE_DIR) > DIRNAME
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR)/src ; $(CONFDEFS) ./configure $(CONFOPTS) )
	# Fixup krb5-config for rpath directory
	# Fixup Makefiles which are missing -lintl
	perl -i -p -e 's,(^SHLIB_EXPLIBS.*),$$1 -lintl,' $(SOURCE_DIR)/src/lib/kadm5/clnt/Makefile
	perl -i -p -e 's,SUPPORT_LIB\) -lcom_err,SUPPORT_LIB\) -lcom_err -lintl,' $(SOURCE_DIR)/src/lib/kadm5/srv/Makefile
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/sbin

	make -C $(SOURCE_DIR)/src
	make -C $(SOURCE_DIR)/src DESTDIR=$(TARGET_DIR) install

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/krb5/plugins/*.so
	cp -a $(TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin/
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	touch .build	

clean:
	-make -C $(SOURCE_DIR)/src clean
	rm -rf $(TARGET_DIR)
	rm -f .build
	rm -f .configured
	
srcclean:
	rm -rf $(SOURCE_DIR)
	rm .source
	rm DIRNAME
