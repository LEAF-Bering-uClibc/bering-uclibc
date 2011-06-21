#############################################################
#
# $Id:
#
#############################################################

include $(MASTERMAKEFILE)
DIR:=readline-6.2
TARGET_DIR:=$(BT_BUILD_DIR)/libreadline
export CC=$(TARGET_CC)

$(DIR)/.source: 		
	zcat $(SOURCE) |  tar -xvf - 	
	touch $(DIR)/.source


$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR); CFLAGS="$(BT_COPT_FLAGS)" ./configure \
	--build=$(GNU_HOST_MANE) \
	--host=$(GNU_TARGET_MANE) \
	--prefix=/usr \
	--with-curses \
	--disable-largefile \
	)
	touch $(DIR)/.configured

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.configured
	-rm -rf $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)
	$(MAKE) -C $(DIR)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	rm -rf $(TARGET_DIR)/usr/share
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libhistory.* 
	rm -f $(BT_STAGING_DIR)/usr/lib/libreadline.* 
	rm -rf $(BT_STAGING_DIR)/usr/include/readline
	$(MAKE) -C $(DIR) clean
	
srcclean:
	rm -rf $(DIR)

