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
	(cd $(LIBNL_DIR) ; CFLAGS="$(BT_COPT_FLAGS) -I$(BT_STAGING_DIR)/include" CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure)
	touch $(LIBNL_DIR)/.configured
                                                                 
$(LIBNL_DIR)/.build: $(LIBNL_DIR)/.configured
	mkdir -p $(LIBNL_TARGET_DIR)
	DEPFLAGS="-I$(BT_STAGING_DIR)/include" make -C $(LIBNL_DIR) all
	mkdir -p $(LIBNL_TARGET_DIR)/usr/lib/pkgconfig
	mkdir -p $(LIBNL_TARGET_DIR)/usr/include
	cp -a $(LIBNL_DIR)/lib/*.so* $(LIBNL_TARGET_DIR)/usr/lib
	cp -ar $(LIBNL_DIR)/include $(LIBNL_TARGET_DIR)/usr
	cp -a $(LIBNL_DIR)/libnl-1.pc $(LIBNL_TARGET_DIR)/usr/lib/pkgconfig
	# PkgConfig file needs to reference /usr/lib rather than /usr/local/lib
	perl -i -p -e "s,/local,," $(LIBNL_TARGET_DIR)/usr/lib/pkgconfig/libnl-1.pc
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNL_TARGET_DIR)/usr/lib/libnl.so.1.1 
	-rm -rf $(LIBNL_TARGET_DIR)/usr/include/linux/netfilter
	-rm -f $(LIBNL_TARGET_DIR)/usr/include/Makefile
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