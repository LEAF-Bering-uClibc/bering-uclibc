# makefile for ulog
include $(MASTERMAKEFILE)

ULOGD_DIR:=ulogd-1.24
ULOGD_TARGET_DIR:=$(BT_BUILD_DIR)/ulogd


$(ULOGD_DIR)/.source:
	bzcat $(ULOGD_SOURCE) | tar -xvf -
	cat $(ULOGD_PATCH1) | patch -d $(ULOGD_DIR) -p1
	cat $(ULOGD_PATCH2) | patch -d $(ULOGD_DIR) -p1
	cat $(ULOGD_PATCH3) | patch -d $(ULOGD_DIR) -p1
	touch $(ULOGD_DIR)/.source

source: $(ULOGD_DIR)/.source

$(ULOGD_DIR)/.configured: $(ULOGD_DIR)/.source
#	(cd $(ULOGD_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS) -I$(BT_LINUX_DIR)/include" \
#	./configure --prefix=/usr --sysconfdir=/etc )
	(cd $(ULOGD_DIR) ; rm aclocal.m4; libtoolize -i -f && autoreconf -i -f && \
	./configure --prefix=/usr --sysconfdir=/etc \
	--host=$(GNU_TARGET_NAME) \
	--with-mysql=$(BT_STAGING_DIR)/usr/ )
	touch $(ULOGD_DIR)/.configured

$(ULOGD_DIR)/.build: $(ULOGD_DIR)/.configured
	mkdir -p $(ULOGD_TARGET_DIR)
	mkdir -p $(ULOGD_TARGET_DIR)/etc/init.d
	mkdir -p $(ULOGD_TARGET_DIR)/etc/cron.daily
	mkdir -p $(ULOGD_TARGET_DIR)/etc/cron.weekly
	mkdir -p $(ULOGD_TARGET_DIR)/usr/lib/ulogd
#multi-threaded make fails, build in single thread
	make -C $(ULOGD_DIR) DESTDIR=$(ULOGD_TARGET_DIR) all
	make DESTDIR=$(ULOGD_TARGET_DIR) -C $(ULOGD_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ULOGD_TARGET_DIR)/usr/sbin/ulogd
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(ULOGD_TARGET_DIR)/usr/lib/ulogd/*.so
	cp -aL ulogd.init $(ULOGD_TARGET_DIR)/etc/init.d/ulogd
	cp -aL ulogd.conf $(ULOGD_TARGET_DIR)/etc/
	cp -aL ulogd_daily $(ULOGD_TARGET_DIR)/etc/cron.daily/ulogd
	cp -aL ulogd_weekly $(ULOGD_TARGET_DIR)/etc/cron.weekly/ulogd
	cp -a $(ULOGD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ULOGD_DIR)/.build

build: $(ULOGD_DIR)/.build

clean:
	make -C $(ULOGD_DIR) clean
	rm -rf $(ULOGD_TARGET_DIR)
	rm $(ULOGD_DIR)/.build
	rm $(ULOGD_DIR)/.configured

srcclean: clean
	rm -rf $(ULOGD_DIR)
	rm $(ULOGD_DIR)/.source
