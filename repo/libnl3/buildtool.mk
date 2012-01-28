# makefile for libnl
include $(MASTERMAKEFILE)

LIBNL_DIR:=libnl-3.2.3
LIBNL_TARGET_DIR:=$(BT_BUILD_DIR)/libnl3

$(LIBNL_DIR)/.source:
	zcat $(LIBNL_SOURCE) | tar -xvf -
	touch $@

source: $(LIBNL_DIR)/.source

$(LIBNL_DIR)/.configured: $(LIBNL_DIR)/.source
	(cd $(LIBNL_DIR) ; ./configure \
	    --host=$(GNU_TARGET_NAME) \
	    --build=$(GNU_BUILD_NAME) \
	    --prefix=/usr \
	    --disable-cli \
	    )
	touch $@

$(LIBNL_DIR)/.build: $(LIBNL_DIR)/.configured
	mkdir -p $(LIBNL_TARGET_DIR)
	make $(MAKEOPTS) -C $(LIBNL_DIR) all
	make DESTDIR=$(LIBNL_TARGET_DIR) -C $(LIBNL_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNL_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBNL_TARGET_DIR)/usr/lib/*.la
	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBNL_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	rm -rf $(LIBNL_TARGET_DIR)/usr/share
	cp -a -f $(LIBNL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBNL_DIR)/.build

build: $(LIBNL_DIR)/.build

clean:
	make -C $(LIBNL_DIR) clean
	rm -rf $(LIBNL_TARGET_DIR)
	rm -rf $(LIBNL_DIR)/.build
	rm -rf $(LIBNL_DIR)/.configured

srcclean: clean
	rm -rf $(LIBNL_DIR)
