# makefile for snarf

SNARF_DIR:=snarf-7.0.orig
SNARF_TARGET_DIR:=$(BT_BUILD_DIR)/snarf

$(SNARF_DIR)/.source:
	zcat $(SNARF_SOURCE) | tar -xvf -
	zcat $(SNARF_PATCH1) | patch -d $(SNARF_DIR) -p1
	cat $(SNARF_PATCH2) | patch -d $(SNARF_DIR) -p1
	touch $(SNARF_DIR)/.source

source: $(SNARF_DIR)/.source

$(SNARF_DIR)/.configured: $(SNARF_DIR)/.source
	(cd $(SNARF_DIR) ; \
	rm -f aclocal.m4 Makefile.in; autoreconf -i -f && \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-guess-winsize)
	touch $(SNARF_DIR)/.configured

$(SNARF_DIR)/.build: $(SNARF_DIR)/.configured
	mkdir -p $(SNARF_TARGET_DIR)
	mkdir -p $(SNARF_TARGET_DIR)/usr/bin
	make $(MAKEOPTS) -C $(SNARF_DIR)
	cp -a $(SNARF_DIR)/snarf $(SNARF_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SNARF_TARGET_DIR)/usr/bin/*
	cp -a $(SNARF_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SNARF_DIR)/.build

build: $(SNARF_DIR)/.build

clean:
	make -C $(SNARF_DIR) clean
	rm -rf $(SNARF_TARGET_DIR)
	rm -f $(SNARF_DIR)/.build
	rm -f $(SNARF_DIR)/.configured

srcclean: clean
	rm -rf $(SNARF_DIR)
