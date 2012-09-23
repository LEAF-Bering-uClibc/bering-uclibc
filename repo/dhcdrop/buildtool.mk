# makefile for dhcpd

DIR:=dhcdrop-0.5
TARGET_DIR:=$(BT_BUILD_DIR)/dhcdrop

$(DIR)/.source:
	bzcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

$(DIR)/Makefile:
	(cd $(DIR) ; ./configure \
	--prefix=/usr \
	--build=$(GNU_BUILD_NAME) \
	--host=$(GNU_TARGET_NAME) )

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/Makefile
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(DIR)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/*
	rm -rf $(TARGET_DIR)/usr/share
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	make -C $(DIR) distclean
	rm -rf $(TARGET_DIR)
	rm $(DIR)/Makefile
	rm $(DIR)/.build

srcclean: clean
	rm -rf $(DIR)
