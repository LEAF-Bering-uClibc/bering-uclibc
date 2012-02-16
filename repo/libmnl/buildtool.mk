# makefile for libnl
include $(MASTERMAKEFILE)

LIBMNL_DIR:=libmnl-1.0.2
LIBMNL_TARGET_DIR:=$(BT_BUILD_DIR)/libmnl

$(LIBMNL_DIR)/.source:
	bzcat $(LIBMNL_SOURCE) | tar -xvf -
	touch $(LIBMNL_DIR)/.source

source: $(LIBMNL_DIR)/.source

$(LIBMNL_DIR)/.configured: $(LIBMNL_DIR)/.source
	(cd $(LIBMNL_DIR) ; ./configure \
	    --host=$(GNU_TARGET_NAME) \
	    --build=$(GNU_BUILD_NAME) \
	    --prefix=/usr \
	    )
	touch $(LIBMNL_DIR)/.configured

$(LIBMNL_DIR)/.build: $(LIBMNL_DIR)/.configured
	mkdir -p $(LIBMNL_TARGET_DIR)
	make $(MAKEOPTS) -C $(LIBMNL_DIR) all
	make DESTDIR=$(LIBMNL_TARGET_DIR) -C $(LIBMNL_DIR) install
	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBMNL_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBNL_TARGET_DIR)/usr/lib/*.la
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBMNL_TARGET_DIR)/usr/lib/*
	cp -a -f $(LIBMNL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBMNL_DIR)/.build

build: $(LIBMNL_DIR)/.build

clean:
	make -C $(LIBMNL_DIR) clean
	rm -rf $(LIBMNL_TARGET_DIR)
	rm -rf $(LIBMNL_DIR)/.build
	rm -rf $(LIBMNL_DIR)/.configured

srcclean: clean
	rm -rf $(LIBMNL_DIR)
	rm -rf $(LIBMNL_DIR)/.source
