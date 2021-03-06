#############################################################
# sysfsutils
#############################################################

DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/sysfsutils

$(DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(SOURCE)
	touch $(DIR)/.source

source:	$(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(BT_BUILD_DIR)/module-init-tools
	(cd $(DIR); rm -rf config.cache; \
		libtoolize -if && aclocal -I m4 && autoheader && \
		automake --add-missing --copy --foreign && autoconf && \
		./configure --prefix=/usr --host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME));
#	cat defs.patch|patch -p1 -d $(DIR)
	make $(MAKEOPTS) -C $(DIR)
	make $(MAKEOPTS) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(TARGET_DIR)/usr/lib/*.la
	-rm -rf $(TARGET_DIR)/usr/share
	-rm -rf $(TARGET_DIR)/usr/man
	cp -R $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build:	$(DIR)/.build

clean:
	make CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) LD=$(TARGET_LD) DESTDIR=$(BT_STAGING_DIR) -C $(DIR) clean
	rm -f $(DIR)/.build
	rm -rf $(BT_BUILD_DIR)/modutils
