## makefile for libnetfilter_log

LIBNETFILTER_LOG_DIR:=libnetfilter_log-1.0.1
LIBNETFILTER_LOG_TARGET_DIR:=$(BT_BUILD_DIR)/libnetfilter_log

$(LIBNETFILTER_LOG_DIR)/.source:
	bzcat $(LIBNETFILTERLOG_SOURCE) |  tar -xvf -
	touch $(LIBNETFILTER_LOG_DIR)/.source

$(LIBNETFILTER_LOG_DIR)/.configured: $(LIBNETFILTER_LOG_DIR)/.source
	(cd $(LIBNETFILTER_LOG_DIR) ; \
	    ./configure \
	    --host=$(GNU_TARGET_NAME) \
	    --target=$(GNU_TARGET_NAME) \
	    --build=$(GNU_BUILD_NAME) \
	    --prefix=/usr )
	touch $(LIBNETFILTER_LOG_DIR)/.configured

source: $(LIBNETFILTER_LOG_DIR)/.source

$(LIBNETFILTER_LOG_DIR)/.build: $(LIBNETFILTER_LOG_DIR)/.configured
	mkdir -p $(LIBNETFILTER_LOG_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include/libnetfilter_log
	$(MAKE) -C $(LIBNETFILTER_LOG_DIR)
	perl -i -p -e "s,-rpath /usr/lib,," $(LIBNETFILTER_LOG_DIR)/src/*.la
	cp $(LIBNETFILTER_LOG_DIR)/src/.libs/libnetfilter_log_libipulog.so.1.0.0 $(LIBNETFILTER_LOG_DIR)/src/.libs/libnetfilter_log_libipulog.so.1.0.0T
	$(MAKE) DESTDIR=$(LIBNETFILTER_LOG_TARGET_DIR) -C $(LIBNETFILTER_LOG_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNETFILTER_LOG_TARGET_DIR)/usr/lib/libnetfilter_log.so*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBNETFILTER_LOG_TARGET_DIR)/usr/lib/*.la
	cp -a $(LIBNETFILTER_LOG_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBNETFILTER_LOG_DIR)/.build

build: $(LIBNETFILTER_LOG_DIR)/.build

clean:
	-rm $(LIBNETFILTER_LOG_DIR)/.build
	rm -rf $(LIBNETFILTER_LOG_TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libnetfilter_log.*
	rm -f $(BT_STAGING_DIR)/usr/lib/pkgconfig/libnetfilter_log.*
	rm -rf $(BT_STAGING_DIR)/usr/include/libnetfilter_log
	$(MAKE) -C $(LIBNETFILTER_LOG_DIR) clean

srcclean:
	rm -rf $(LIBNETFILTER_LOG_DIR)
