######################################
#
# buildtool make file for oprofile
#
######################################

DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/oprofile

export LDFLAGS += $(EXTCCLDFLAGS)

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -d $(DIR) -p1 
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; \
	./configure --prefix=/usr \
	--with-kernel-support \
	--with-sysroot=$(BT_STAGING_DIR) \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	)
	touch $(DIR)/.configured

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	mkdir -p $(BT_STAGING_DIR)/usr/share/oprofile
	make $(MAKEOPTS) -C $(DIR)
	make -C $(DIR) DESTDIR=$(TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/oprofile/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib/oprofile\'," $(TARGET_DIR)/usr/lib/oprofile/*.la
	cp -a $(TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
	(cd $(TARGET_DIR)/usr/share/oprofile; \
		cp -a stl.pat i386 x86-64 $(BT_STAGING_DIR)/usr/share/oprofile)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	make -C $(DIR) clean
	rm -rf $(TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/sbin/tcpdump
	rm -f $(DIR)/.build
	rm -f $(DIR)/.configured

srcclean: clean
	rm -rf $(DIR)

