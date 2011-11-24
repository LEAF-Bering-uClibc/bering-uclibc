#############################################################
#
# mini_httpd
#
#############################################################

include $(MASTERMAKEFILE)
MINI_HTTPD_DIR:=mini_httpd-1.19
MINI_HTTPD_TARGET_DIR:=$(BT_BUILD_DIR)/mini_httpd
export CC=$(TARGET_CC)
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment

$(MINI_HTTPD_DIR)/.source:
	zcat $(MINI_HTTPD_SOURCE) |  tar -xvf -
	touch $(MINI_HTTPD_DIR)/.source


$(MINI_HTTPD_DIR)/.configured: $(MINI_HTTPD_DIR)/.source
	#perl -i -p -e 's,#define\s*SERVER_SOFTWARE.*,#define SERVER_SOFTWARE "mini_httpd/1.17",' $(MINI_HTTPD_DIR)/version.h
	perl -i -p -e 's,<BODY\s*BGCOLOR.*$$,<BODY>\\n\\,' $(MINI_HTTPD_DIR)/mini_httpd.c
	perl -i -p -e 's,CFLAGS\s*=\s*-O\s*(.*)$$,CFLAGS=$(CFLAGS) $$1,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's/^CC\s*=.*$$/CC = $(TARGET_CC)/' $(MINI_HTTPD_DIR)/Makefile
	echo "lrp	application/octet-stream" >> $(MINI_HTTPD_DIR)/mime_types.txt
	touch $(MINI_HTTPD_DIR)/.configured


$(MINI_HTTPD_DIR)/.build: $(MINI_HTTPD_DIR)/.configured
	mkdir -p $(MINI_HTTPD_TARGET_DIR)/usr/bin
	mkdir -p $(MINI_HTTPD_TARGET_DIR)/usr/man/man1
	mkdir -p $(MINI_HTTPD_TARGET_DIR)/usr/man/man8
	mkdir -p $(MINI_HTTPD_TARGET_DIR)/etc/init.d
	mkdir -p $(MINI_HTTPD_TARGET_DIR)/etc/cron.daily
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/etc/cron.daily

	perl -i -p -e 's,#SSL_TREE\s*=.*,SSL_TREE = $(BT_STAGING_DIR)/usr,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,#SSL_DEFS,SSL_DEFS,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,#SSL_INC,SSL_INC,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,#SSL_LIBS,SSL_LIBS,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,BINDIR\s*=.*,BINDIR = $(MINI_HTTPD_TARGET_DIR)/usr/bin,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,MANDIR\s*=.*,MANDIR = $(MINI_HTTPD_TARGET_DIR)/usr/man,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,# define HAVE_SENDFILE,/* HAVE_SENDFILE is not set */,' $(MINI_HTTPD_DIR)/port.h
	perl -i -p -e 's,# define HAVE_LINUX_SENDFILE,/* HAVE_LINUX_SENDFILE is not set */,' $(MINI_HTTPD_DIR)/port.h

	$(MAKE) $(MAKEOPTS) -C $(MINI_HTTPD_DIR)
	$(MAKE) -C $(MINI_HTTPD_DIR) install
	mv $(MINI_HTTPD_TARGET_DIR)/usr/bin/mini_httpd $(MINI_HTTPD_TARGET_DIR)/usr/bin/mini_httpd.ssl

	$(MAKE) -C $(MINI_HTTPD_DIR) clean
	perl -i -p -e 's,^\s*SSL_TREE,#SSL_TREE,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,^\s*SSL_DEFS,#SSL_DEFS,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,^\s*SSL_INC,#SSL_INC,' $(MINI_HTTPD_DIR)/Makefile
	perl -i -p -e 's,^\s*SSL_LIBS,#SSL_LIBS,' $(MINI_HTTPD_DIR)/Makefile
	$(MAKE) $(MAKEOPTS) -C $(MINI_HTTPD_DIR)
	$(MAKE) -C $(MINI_HTTPD_DIR) install

	cp -aL mini_httpd $(MINI_HTTPD_TARGET_DIR)/etc/init.d/
	cp -aL mini_httpds $(MINI_HTTPD_TARGET_DIR)/etc/init.d/
	cp -aL savelog-mini_httpd $(MINI_HTTPD_TARGET_DIR)/etc/cron.daily/
	cp -aL savelog-mini_httpds $(MINI_HTTPD_TARGET_DIR)/etc/cron.daily/

	-cp -aL mini_httpds.conf $(BT_STAGING_DIR)/etc/
	-cp -aL mini_httpd.conf $(BT_STAGING_DIR)/etc/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MINI_HTTPD_TARGET_DIR)/usr/bin/*
	-cp -a $(MINI_HTTPD_TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	-cp -a $(MINI_HTTPD_TARGET_DIR)/etc/init.d/* $(BT_STAGING_DIR)/etc/init.d/
	-cp -a $(MINI_HTTPD_TARGET_DIR)/etc/cron.daily/* $(BT_STAGING_DIR)/etc/cron.daily/

	touch $(MINI_HTTPD_DIR)/.build

source: $(MINI_HTTPD_DIR)/.source

build: $(MINI_HTTPD_DIR)/.build

clean:
	-rm $(MINI_HTTPD_DIR)/.build
	rm -rf $(MINI_HTTPD_TARGET_DIR)
	$(MAKE) -C $(MINI_HTTPD_DIR) clean

srcclean:
	rm -rf $(MINI_HTTPD_DIR)

