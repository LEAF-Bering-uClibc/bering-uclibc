######################################
#
# buildtool make file for pcre
#
######################################

include $(MASTERMAKEFILE)

PCRE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(PCRE_SOURCE) 2>/dev/null )
ifeq ($(PCRE_DIR),)
PCRE_DIR:=$(shell cat DIRNAME)
endif
PCRE_TARGET_DIR:=$(BT_BUILD_DIR)/pcre

CONFFLAGS:= --prefix=/usr --disable-cpp


$(PCRE_DIR)/.source:
	zcat $(PCRE_SOURCE) | tar -xvf -
	echo $(PCRE_DIR) > DIRNAME
	touch $(PCRE_DIR)/.source	

source: $(PCRE_DIR)/.source


$(PCRE_DIR)/.configured: $(PCRE_DIR)/.source
	(cd $(PCRE_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure $(CONFFLAGS) --prefix=$(PCRE_TARGET_DIR)/usr )
	touch $(PCRE_DIR)/.configured


$(PCRE_DIR)/.build: $(PCRE_DIR)/.configured
	mkdir -p $(PCRE_TARGET_DIR)
	make -C $(PCRE_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)"  
	make -C $(PCRE_DIR) install
#	make -C $(PCRE_DIR) DESTDIR=$(PCRE_TARGET_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PCRE_TARGET_DIR)/usr/lib/libpcre.so.0.0.1
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(PCRE_TARGET_DIR)/usr/lib/libpcreposix.so.0.0.0
	cp -a -f $(PCRE_TARGET_DIR)/usr/lib/libpcre.* $(BT_STAGING_DIR)/usr/lib/
	cp -a -f $(PCRE_TARGET_DIR)/usr/include/pcre.* $(BT_STAGING_DIR)/usr/include/
	touch $(PCRE_DIR)/.build


build: $(PCRE_DIR)/.build


clean:
	make -C $(PCRE_DIR) clean
	rm -rf $(PCRE_TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/lib/libpcre*
	rm -rf $(BT_STAGING_DIR)/usr/include/pcre*
	rm -f $(PCRE_DIR)/.build
	rm -f $(PCRE_DIR)/.configured


srcclean: clean
	rm -rf $(PCRE_DIR)
	rm -f $(PCRE_DIR)/.source
	-rm DIRNAME
