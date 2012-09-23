
MPG123_DIR:=mpg123-0.60

$(MPG123_DIR)/.source:
	zcat $(MPG123_SOURCE) | tar -xvf -
	touch $(MPG123_DIR)/.source

$(MPG123_DIR)/.build: $(MPG123_DIR)/.source
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	(cd $(MPG123_DIR); CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) \
		./configure --with-audio=oss --disable-debug --prefix=/usr \
			--with-optimization=0 --with-cpu=i486)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/mpg123 $(BT_STAGING_DIR)/usr/bin/mpg123_i486
	$(MAKE) -C $(MPG123_DIR) clean
	(cd $(MPG123_DIR); CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) \
		./configure --with-audio=oss --disable-debug --prefix=/usr \
			--with-optimization=0 --with-cpu=i586)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/mpg123 $(BT_STAGING_DIR)/usr/bin/mpg123_pentium
	$(MAKE) -C $(MPG123_DIR) clean
	(cd $(MPG123_DIR); CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) \
		./configure --with-audio=oss --disable-debug --prefix=/usr \
			--with-optimization=0 --with-cpu=3dnow)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/mpg123 $(BT_STAGING_DIR)/usr/bin/mpg123_3dnow
	$(MAKE) -C $(MPG123_DIR) clean
	(cd $(MPG123_DIR); CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) \
		./configure --with-audio=oss --disable-debug --prefix=/usr \
			--with-optimization=0 --with-cpu=mmx)
	$(MAKE) -C $(MPG123_DIR)
	cp -a -f $(MPG123_DIR)/src/mpg123 $(BT_STAGING_DIR)/usr/bin/mpg123_mmx
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BT_STAGING_DIR)/usr/bin/mpg123_*
	touch $(MPG123_DIR)/.build

source: $(MPG123_DIR)/.source

build: $(MPG123_DIR)/.build

clean:
	-rm $(MPG123_DIR)/.build
	$(MAKE) -C $(MPG123_DIR) clean
	rm -f $(BT_STAGING_DIR)/usr/bin/mpg123_*

srcclean:
	rm -rf $(MPG123_DIR)
