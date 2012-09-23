#############################################################
#
# elfutils
# Currently we need only libelf from it.
#
#############################################################

DIR:=elfutils-0.148
TARGET_DIR:=$(BT_BUILD_DIR)/libelf

$(DIR)/.source:
	bzcat $(SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(DIR)
	touch $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR); ./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--prefix=/usr \
			--disable-nls);
	touch $(DIR)/.configured

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(DIR)/libelf
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(DIR)/libelf install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	$(MAKE) -C $(DIR)/libelf clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libelf.*

srcclean:
	rm -rf $(DIR)
