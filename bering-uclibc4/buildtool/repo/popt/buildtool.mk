#############################################################
#
# libpcap
#
#############################################################

include $(MASTERMAKEFILE)

LIBPOPT_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBPOPT_SOURCE) 2>/dev/null )
ifeq ($(LIBPOPT_DIR),)
LIBPOPT_DIR:=$(shell cat DIRNAME)
endif
LIBPOPT_TARGET_DIR:=$(BT_BUILD_DIR)/libpopt

export CC=$(TARGET_CC)

$(LIBPOPT_DIR)/.source:
	zcat $(LIBPOPT_SOURCE) |  tar -xvf - 	
	zcat $(LIBPOPT_PATCH1) |  patch -d $(LIBPOPT_DIR) -p1  
	zcat $(LIBPOPT_PATCH2) |  patch -d $(LIBPOPT_DIR) -p1  
	echo $(LIBPOPT_DIR) > DIRNAME
	touch $(LIBPOPT_DIR)/.source

$(LIBPOPT_DIR)/.configured: $(LIBPOPT_DIR)/.source
	(cd $(LIBPOPT_DIR); ac_cv_linux_vers=2  \
		./configure \
			--build=i386-pc-linux-gnu \
			--target=i386-pc-linux-gnu \
			--prefix=/usr \
			--disable-nls );
	touch $(LIBPOPT_DIR)/.configured
	
source: $(LIBPOPT_DIR)/.source


$(LIBPOPT_DIR)/.build: $(LIBPOPT_DIR)/.configured
	mkdir -p $(LIBPOPT_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	$(MAKE) CCOPT="$(BT_COPT_FLAGS)" -C $(LIBPOPT_DIR) 	
	$(BT_STRIP)  --strip-unneeded $(LIBPOPT_DIR)/.libs/libpopt.so.0.0.0
	$(MAKE) DESTDIR=$(LIBPOPT_TARGET_DIR) -C $(LIBPOPT_DIR) install
	cp -a -f $(LIBPOPT_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a -f $(LIBPOPT_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/	
	touch $(LIBPOPT_DIR)/.build

build: $(LIBPOPT_DIR)/.build

clean:
	echo $(PATH)
	-rm $(LIBPOPT_DIR)/.build
#	rm -rf $(LIBPOPT_TARGET_DIR)
	$(MAKE) -C $(LIBPOPT_DIR) clean
	
srcclean:
	rm -rf $(LIBPOPT_DIR)
