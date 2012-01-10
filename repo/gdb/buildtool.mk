#############################################################
#
# elfutils
# Currently we need only libelf from it.
#
#############################################################

include $(MASTERMAKEFILE)
DIR:=gdb-7.3.1
TARGET_DIR:=$(BT_BUILD_DIR)/gdb

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(DIR)
	touch $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR); ./configure \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr \
			);
	touch $(DIR)/.configured

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(DIR)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-rm -rf $(TARGET_DIR)/usr/lib/*.a
	-rm -rf $(TARGET_DIR)/usr/lib/*.la
	-rm -rf $(TARGET_DIR)/usr/include
	-rm -rf $(TARGET_DIR)/usr/share/info
	-rm -rf $(TARGET_DIR)/usr/share/locale
	-rm -rf $(TARGET_DIR)/usr/share/man
	-rm -rf $(TARGET_DIR)/usr/share/gdb/python
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	$(MAKE) -C $(DIR) clean

srcclean:
	rm -rf $(DIR)
