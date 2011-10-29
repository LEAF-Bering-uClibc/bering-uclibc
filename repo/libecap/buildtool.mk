#############################################################
#
# libecap
#
#############################################################

include $(MASTERMAKEFILE)
LIBECAP_DIR:=libecap-0.2.0
LIBECAP_TARGET_DIR:=$(BT_BUILD_DIR)/libecap
export CC=$(TARGET_CC)

source:
	zcat $(LIBECAP_SOURCE) | tar -xvf - 	

$(LIBECAP_DIR)/Makefile: $(LIBECAP_DIR)/configure
	(cd $(LIBECAP_DIR); ac_cv_linux_vers=2  \
		CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS=$(CFLAGS) \
		./configure \
			--build=i686-pc-linux-gnu \
			--target=i686-pc-linux-gnu \
			--prefix=/usr );
	
build: $(LIBECAP_DIR)/Makefile
	mkdir -p $(LIBECAP_TARGET_DIR)
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBECAP_DIR) 
	$(MAKE) DESTDIR=$(LIBECAP_TARGET_DIR) -C $(LIBECAP_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBECAP_TARGET_DIR)/usr/lib/libecap.so.2.0.0
	rm -rf $(LIBECAP_TARGET_DIR)/usr/man
	cp -a $(LIBECAP_TARGET_DIR)/* $(BT_STAGING_DIR)


clean:
	echo $(PATH)
	-rm $(LIBECAP_DIR)/.build
	rm -rf $(LIBECAP_TARGET_DIR)
	$(MAKE) -C $(LIBECAP_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/lib/libecap*
	
srcclean: clean
	rm -rf $(LIBECAP_DIR)
