# makefile for tftp
include $(MASTERMAKEFILE)

DIR:=mbus-0.1.2
TARGET_DIR:=$(BT_BUILD_DIR)/mbusd

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(DIR)
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; rm -f aclocal.m4 Makefile.in ; libtoolize -if && \
	 CFLAGS="$(CFLAGS) -DTRXCTL" \
	./autogen.sh --prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	touch $(DIR)/.configured

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/bin
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/etc/default
	make $(MAKEOPTS) -C $(DIR)
	cp -a $(DIR)/src/mbusd $(TARGET_DIR)/usr/bin
	cp -aL mbusd.init $(TARGET_DIR)/etc/init.d/mbusd
	cp -aL mbusd.default $(TARGET_DIR)/etc/default/mbusd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	make -C $(DIR) clean
	rm -rf $(TARGET_DIR)
	rm -rf $(DIR)/.build
	rm -rf $(DIR)/.configured

srcclean: clean
	rm -rf $(DIR)
