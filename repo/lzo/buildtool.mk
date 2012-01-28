#############################################################
#
# lzo
#
#############################################################

include $(MASTERMAKEFILE)

LZO_DIR:=lzo-2.06
LZO_TARGET_DIR:=$(BT_BUILD_DIR)/lzo


$(LZO_DIR)/.source:
	zcat $(LZO_SOURCE) | tar -xvf -
	touch $(LZO_DIR)/.source

$(LZO_DIR)/.configured: $(LZO_DIR)/.source
	(cd $(LZO_DIR); \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_BUILD_NAME) \
			--enable-shared \
			--prefix=/usr );
		touch $(LZO_DIR)/.configured


source: $(LZO_DIR)/.source

$(LZO_DIR)/.build: $(LZO_DIR)/.configured
	mkdir -p $(LZO_TARGET_DIR)
	make $(MAKEOPTS) -C $(LZO_DIR)
	make DESTDIR=$(LZO_TARGET_DIR) -C $(LZO_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LZO_TARGET_DIR)/usr/lib/*
	rm -rf $(LZO_TARGET_DIR)/usr/share
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LZO_TARGET_DIR)/usr/lib/*.la
	cp -a $(LZO_TARGET_DIR)/* $(BT_STAGING_DIR)
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


