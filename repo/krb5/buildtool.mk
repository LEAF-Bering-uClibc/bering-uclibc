#############################################################
#
# buildtool makefile for krb5
#
#############################################################


SOURCE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(KRB5_SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/krb5

# krb5 needs 02, build fails with -Os
export CFLAGS=-O2 $(ARCH_CFLAGS) -I$(BT_STAGING_DIR)/usr/include

# Variable definitions for 'configure'
CONFDEFS = \
	krb5_cv_attr_constructor_destructor=yes,yes

# Option settings for 'configure'
CONFOPTS = \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr \
	--with-ldap \
	--enable-dns-for-realm

.source:
	$(BT_SETUP_BUILDDIR) -v $(KRB5_SOURCE) 
#	zcat $(SOURCE_TGZ) | tar -xvf -
	touch .source

source: .source

.configured: .source
	( cd $(SOURCE_DIR)/src ; $(CONFDEFS) ./configure $(CONFOPTS) )
	# Hack PROG_RPATH setting in all Makefiles
	( cd $(SOURCE_DIR)/src ; find . -name Makefile -exec perl -i -p -e "s,^PROG_RPATH=.*,PROG_RPATH=$(BT_STAGING_DIR)/usr/lib," {} \; )
	# Fixup Makefiles which are missing -lintl
	perl -i -p -e 's,(^SHLIB_EXPLIBS.*),$$1 -lintl,' $(SOURCE_DIR)/src/lib/kadm5/clnt/Makefile
	perl -i -p -e 's,SUPPORT_LIB\) -lcom_err,SUPPORT_LIB\) -lcom_err -lintl,' $(SOURCE_DIR)/src/lib/kadm5/srv/Makefile
	touch .configured

build: .configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/usr/include

	make -C $(SOURCE_DIR)/src
	make -C $(SOURCE_DIR)/src DESTDIR=$(TARGET_DIR) install

	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*.so
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
