#############################
# makefile for mpg123
##############################

MPG123_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(MPG123_SOURCE) 2>/dev/null )
MPG123_TARGET_DIR:=$(BT_BUILD_DIR)/mpg123

$(MPG123_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(MPG123_SOURCE)
	touch $(MPG123_DIR)/.source

$(MPG123_DIR)/.build: $(MPG123_DIR)/.source
	mkdir -p $(MPG123_TARGET_DIR)/usr/bin
	mkdir -p $(MPG123_TARGET_DIR)/usr/lib

# optimized for i486
	(cd $(MPG123_DIR); CFLAGS="$(CFLAGS)" CC=$(TARGET_CC) \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--with-audio=oss \
	--disable-debug \
	--enable-network \
	--prefix=/usr \
	--with-cpu=i486) 
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/.libs/mpg123 $(MPG123_TARGET_DIR)/usr/bin/mpg123_i486
	cp -a -f $(MPG123_DIR)/src/.libs/mpg123-* $(MPG123_TARGET_DIR)/usr/bin/
	cp -a -f $(MPG123_DIR)/src/.libs/out123 $(MPG123_TARGET_DIR)/usr/bin/
	cp -a -f $(MPG123_DIR)/src/libmpg123/.libs/libmpg123.so.0.40.3 $(MPG123_TARGET_DIR)/usr/lib/libmpg123.so.0.40.3_i486
	$(MAKE) -C $(MPG123_DIR) clean

# optimized for pentium
	(cd $(MPG123_DIR); CFLAGS="$(CFLAGS)" CC=$(TARGET_CC) \
	./configure --with-audio=oss \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-debug \
	--enable-network \
	--prefix=/usr \
	--with-cpu=i586)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/.libs/mpg123 $(MPG123_TARGET_DIR)/usr/bin/mpg123_pentium
	cp -a -f $(MPG123_DIR)/src/libmpg123/.libs/libmpg123.so.0.40.3 $(MPG123_TARGET_DIR)/usr/lib/libmpg123.so.0.40.3_pentium
	$(MAKE) -C $(MPG123_DIR) clean

# optimized for 3dnow
	(cd $(MPG123_DIR); CFLAGS="$(CFLAGS)" CC=$(TARGET_CC) \
	./configure --with-audio=oss \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-debug \
	--enable-network \
	--prefix=/usr \
	--with-cpu=3dnow)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/.libs/mpg123 $(MPG123_TARGET_DIR)/usr/bin/mpg123_3dnow
	cp -a -f $(MPG123_DIR)/src/libmpg123/.libs/libmpg123.so.0.40.3 $(MPG123_TARGET_DIR)/usr/lib/libmpg123.so.0.40.3_3dnow
	$(MAKE) -C $(MPG123_DIR) clean

# optimized for mmx
	(cd $(MPG123_DIR); CFLAGS="$(CFLAGS)" CC=$(TARGET_CC) \
	./configure --with-audio=oss \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-debug \
	--enable-network \
	--prefix=/usr \
	--with-cpu=mmx)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/.libs/mpg123 $(MPG123_TARGET_DIR)/usr/bin/mpg123_mmx
	cp -a -f $(MPG123_DIR)/src/libmpg123/.libs/libmpg123.so.0.40.3 $(MPG123_TARGET_DIR)/usr/lib/libmpg123.so.0.40.3_mmx
	cp -a $(MPG123_TARGET_DIR)/* $(BT_STAGING_DIR)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BT_STAGING_DIR)/usr/bin/mpg123_*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BT_STAGING_DIR)/usr/lib/libmpg123_*
	touch $(MPG123_DIR)/.build

source: $(MPG123_DIR)/.source

build: $(MPG123_DIR)/.build

clean:
	-rm $(MPG123_DIR)/.build
	$(MAKE) -C $(MPG123_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/bin/mpg123_*
	rm -f $(BT_STAGING_DIR)/usr/lib/libmpg123*
	rm -rf $(MPG123_TARGET_DIR)/usr/*

srcclean: clean
	rm -rf $(MPG123_DIR)
