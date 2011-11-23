######################################
#
# buildtool make file for mysql
#
######################################

include $(MASTERMAKEFILE)

MYSQL_DIR:=mysql-5.0.91
MYSQL_TARGET_DIR:=$(BT_BUILD_DIR)/mysql


CONFFLAGS:= --prefix=/usr \
	--without-server \
	--without-extra-tools \
	--without-docs \
	--without-bench \
	--without-debug \
	--enable-thread-safe-client


$(MYSQL_DIR)/.source:
	zcat $(MYSQL_SOURCE) | tar -xvf -
#	cat $(MYSQL_PATCH1) | patch -d $(MYSQL_DIR) -p1
	touch $(MYSQL_DIR)/.source

source: $(MYSQL_DIR)/.source


$(MYSQL_DIR)/.configured: $(MYSQL_DIR)/.source
	(cd $(MYSQL_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure $(CONFFLAGS) )
	touch $(MYSQL_DIR)/.configured


$(MYSQL_DIR)/.build: $(MYSQL_DIR)/.configured
	mkdir -p $(MYSQL_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/include/mysql
	make -C $(MYSQL_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="-Os"
	make -C $(MYSQL_DIR) DESTDIR=$(MYSQL_TARGET_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIB) $(MYSQL_TARGET_DIR)/usr/lib/mysql/libmysqlclient.so.15.0.0
	$(BT_STRIP) $(BT_STRIP_LIB) $(MYSQL_TARGET_DIR)/usr/lib/mysql/libmysqlclient_r.so.15.0.0
	-$(BT_STRIP) $(BT_STRIP_BIN) $(MYSQL_TARGET_DIR)/usr/bin/*
	perl -i -p -e 's,/usr/lib/mysql,$(BT_STAGING_DIR)/usr/lib/,g' $(MYSQL_TARGET_DIR)/usr/lib/mysql/*.la
	cp -a -f $(MYSQL_TARGET_DIR)/usr/lib/mysql/* $(BT_STAGING_DIR)/usr/lib/
	cp -a -f $(MYSQL_TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -a -f $(MYSQL_TARGET_DIR)/usr/include/mysql/* $(BT_STAGING_DIR)/usr/include/mysql
	touch $(MYSQL_DIR)/.build


build: $(MYSQL_DIR)/.build


clean:
	make -C $(MYSQL_DIR) clean
	rm -rf $(MYSQL_TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/lib/libdbug.a
	rm -rf $(BT_STAGING_DIR)/usr/lib/libheap.a
	rm -rf $(BT_STAGING_DIR)/usr/lib/libmerge.a
	rm -rf $(BT_STAGING_DIR)/usr/lib/libmyisam*
	rm -rf $(BT_STAGING_DIR)/usr/lib/libmysqlclient*
	rm -rf $(BT_STAGING_DIR)/usr/lib/libmystrings.a
	rm -rf $(BT_STAGING_DIR)/usr/lib/libmysys.a
	rm -rf $(BT_STAGING_DIR)/usr/lib/libnisam.a
	rm -rf $(BT_STAGING_DIR)/usr/lib/libvio.a
	rm -rf $(BT_STAGING_DIR)/usr/include/mysql
	rm -f $(MYSQL_DIR)/.build
	rm -f $(MYSQL_DIR)/.configured


srcclean: clean
	rm -rf $(MYSQL_DIR)

