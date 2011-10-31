# makefile for clamav
include $(MASTERMAKEFILE)

CLAMAV_DIR:=clamav-0.97.3
CLAMAV_TARGET_DIR:=$(BT_BUILD_DIR)/clamav

$(CLAMAV_DIR)/.source:
	zcat $(CLAMAV_SOURCE) | tar -xvf -
	cat $(CLAMAV_PATCH1) | patch -d $(CLAMAV_DIR) -p1
	touch $(CLAMAV_DIR)/.source

source: $(CLAMAV_DIR)/.source
                        
$(CLAMAV_DIR)/.configured: $(CLAMAV_DIR)/.source
	(cd $(CLAMAV_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure \
	--sysconfdir=/etc/clamav --prefix= \
	--exec-prefix=/usr --libexecdir=/usr/bin \
	--disable-clamav \
	--disable-clamuko \
	--disable-dsig \
	--disable-dns \
	--with-user=root \
	--with-group=root \
	--disable-nls \
	--without-iconv \
	--disable-static \
	--disable-llvm \
	--without-libcurl \
	--with-zlib=$(BT_STAGING_DIR)/usr \
	--disable-zlib-vcheck \
	--disable-unrar \
	--datadir=/etc/clamav )
	touch $(CLAMAV_DIR)/.configured
                                                                 
$(CLAMAV_DIR)/.build: $(CLAMAV_DIR)/.configured
	mkdir -p $(CLAMAV_TARGET_DIR)
	mkdir -p $(CLAMAV_TARGET_DIR)/etc/clamav	
	mkdir -p $(CLAMAV_TARGET_DIR)/etc/init.d	
	mkdir -p $(CLAMAV_TARGET_DIR)/usr/sbin	
	mkdir -p $(CLAMAV_TARGET_DIR)/usr/bin
	make -C $(CLAMAV_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) all	

	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(CLAMAV_DIR)/libclamav/.libs/libclamav.so.6.1.12

	make -C $(CLAMAV_DIR) DESTDIR=$(CLAMAV_TARGET_DIR) install
	rm -rf $(CLAMAV_TARGET_DIR)/share/man
	cp -aL clamd.conf $(CLAMAV_TARGET_DIR)/etc/clamav
	cp -aL freshclam.conf $(CLAMAV_TARGET_DIR)/etc/clamav
	cp -aL rc.freshclam $(CLAMAV_TARGET_DIR)/etc/init.d/freshclam
	cp -aL rc.clamd $(CLAMAV_TARGET_DIR)/etc/init.d/clamd
	cp -a $(CLAMAV_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(CLAMAV_DIR)/.build

build: $(CLAMAV_DIR)/.build
                                                                                         
clean:
	make -C $(CLAMAV_DIR) clean
	rm -rf $(CLAMAV_TARGET_DIR)
	rm -rf $(CLAMAV_DIR)/.build
	rm -rf $(CLAMAV_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(CLAMAV_DIR) 
	rm -rf $(CLAMAV_DIR)/.source