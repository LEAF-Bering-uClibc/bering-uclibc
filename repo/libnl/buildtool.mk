# makefile for libnl
include $(MASTERMAKEFILE)

LIBNL_DIR:=libnl-1.1
LIBNL_TARGET_DIR:=$(BT_BUILD_DIR)/libnl

$(LIBNL_DIR)/.source:
	zcat $(LIBNL_SOURCE) | tar -xvf -
	cat $(LIBNL_PATCH) | patch -p1 -d $(LIBNL_DIR)
	(cd $(LIBNL_DIR)/include/linux; rm -f `ls *.h|grep -v ip_mp_alg`)
	touch $(LIBNL_DIR)/.source

source: $(LIBNL_DIR)/.source

$(LIBNL_DIR)/.configured: $(LIBNL_DIR)/.source
	(cd $(LIBNL_DIR) ; ./configure \
	    --host=$(GNU_TARGET_NAME) \
	    --build=$(GNU_BUILD_NAME) \
	    --prefix=/usr \
	    )
	touch $(LIBNL_DIR)/.configured

$(LIBNL_DIR)/.build: $(LIBNL_DIR)/.configured
	mkdir -p $(LIBNL_TARGET_DIR)
	make $(MAKEOPTS) -C $(LIBNL_DIR) all
	make DESTDIR=$(LIBNL_TARGET_DIR) -C $(LIBNL_DIR) install
	cp -a $(LIBNL_DIR)/lib/*.so* $(LIBNL_TARGET_DIR)/usr/lib
	cp -ar $(LIBNL_DIR)/include $(LIBNL_TARGET_DIR)/usr
	cp -a $(LIBNL_DIR)/libnl-1.pc $(LIBNL_TARGET_DIR)/usr/lib/pkgconfig
#	perl -i -p -e "s,=/usr,=$(BT_STAGING_DIR)/usr," $(LIBNL_TARGET_DIR)/usr/lib/pkgconfig/*.pc
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNL_TARGET_DIR)/usr/lib/*
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
	rm -rf $(LIBNL_DIR)/.source
