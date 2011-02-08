#############################################################
#
# mtools
#
#############################################################

include $(MASTERMAKEFILE)
MTOOLS_DIR:=mtools-3.9.9
MTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/mtools
export CC=$(TARGET_CC)


$(MTOOLS_DIR)/.source: 
	zcat $(MTOOLS_SOURCE) |  tar -xvf - 
	zcat $(MTOOLS_PATCH1) | patch -d $(MTOOLS_DIR) -p1
	#perl -i -p -e 's,CC\s*=\s*gcc,#CC = gcc,' $(MTOOLS_DIR)/Makefile
	#perl -i -p -e 's,PREFIX\s*=.*,PREFIX = $(MTOOLS_TARGET_DIR),' $(MTOOLS_DIR)/Makefile
	-mkdir $(MTOOLS_TARGET_DIR)
	touch $(MTOOLS_DIR)/.source	

$(MTOOLS_DIR)/.configured: $(MTOOLS_DIR)/.source

	( cd $(MTOOLS_DIR) ; CFLAGS="$(BT_COPT_FLAGS) -Wall" ./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--target=i386-pc-linux-gnu \
		--with-build-libs="$(BT_STAGING_DIR)/lib" \
		--disable-floppyd \
		--disable-debug \
		--disable-new-vold \
		--disable-vold 	;)
	touch $(MTOOLS_DIR)/.configured		

$(MTOOLS_DIR)/.build: $(MTOOLS_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(MTOOLS_DIR) 
	-$(BT_STRIP) --strip-unneeded $(MTOOLS_DIR)/mtools
	cp $(MTOOLS_DIR)/mtools $(MTOOLS_TARGET_DIR)/
	cp $(MTOOLS_DIR)/debian/mtools.conf $(MTOOLS_TARGET_DIR)/
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	cp $(MTOOLS_TARGET_DIR)/*  $(BT_STAGING_DIR)/usr/bin
	touch $(MTOOLS_DIR)/.build

source: $(MTOOLS_DIR)/.source 

build: $(MTOOLS_DIR)/.build

clean:
	rm -rf $(MTOOLS_TARGET_DIR)
	-rm $(MTOOLS_DIR)/.build
	$(MAKE) -C $(MTOOLS_DIR) clean
  
srcclean:
	rm -rf $(MTOOLS_DIR)
