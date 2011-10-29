#############################################################
#
# lzo
#
#############################################################
 
include $(MASTERMAKEFILE)

LZO_DIR:=lzo-2.06
LZO_TARGET_DIR:=$(BT_BUILD_DIR)/lzo
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment 


$(LZO_DIR)/.source:
	zcat $(LZO_SOURCE) | tar -xvf -
	touch $(LZO_DIR)/.source

$(LZO_DIR)/.configured: $(LZO_DIR)/.source
	(cd $(LZO_DIR); \
		rm -f config.cache; \
		CFLAGS="$(BT_COPT_FLAGS)" \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		./configure \
			--enable-shared \
			--prefix=/usr );
		touch $(LZO_DIR)/.configured


source: $(LZO_DIR)/.source
	
$(LZO_DIR)/.build: $(LZO_DIR)/.configured
	make CC=$(TARGET_CC) -C $(LZO_DIR)
	make DESTDIR=$(LZO_TARGET_DIR) -C $(LZO_DIR) install 
	make DESTDIR=$(BT_STAGING_DIR) -C $(LZO_DIR) install 
	$(BT_STRIP) --strip-unneeded $(LZO_TARGET_DIR)/usr/lib/liblzo2.so.2.0.0
	$(BT_STRIP) --strip-unneeded $(BT_STAGING_DIR)/usr/lib/liblzo2.so.2.0.0
	touch $(LZO_DIR)/.build
	
build: $(LZO_DIR)/.build	

clean:
	-rm $(LZO_DIR)/.build
	make -C $(LZO_DIR) clean
	rm -rf $(LZO_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/liblzo*
	rm -rf $(BT_STAGING_DIR)/usr/include/lzo*


srcclean:
	rm -rf $(LZO_DIR)
	rm -rf $(LZO_TARGET_DIR)


