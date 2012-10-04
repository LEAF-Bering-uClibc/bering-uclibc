# buildtool.mk for fwlogwatch

FWLOGWATCH_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(FWLOGWATCH_SOURCE) 2>/dev/null )
FWLOGWATCH_TARGET_DIR:=$(BT_BUILD_DIR)/fwlogwatch

.source:
	$(BT_SETUP_BUILDDIR) -v $(FWLOGWATCH_SOURCE)
	touch .source

source: .source

$(FWLOGWATCH_DIR)/.configured: .source
	(cd $(FWLOGWATCH_DIR); \
	perl -i -p -e "s,-DHAVE_GETTEXT,," Makefile; \
	perl -i -p -e "s,/usr/local/sbin/fwlogwatch,/usr/bin/fwlogwatch," contrib/fwlogsummary_small.cgi; \
	perl -i -p -e "s,/etc,/etc/fwlogwatch," main.h; \
	perl -i -p -e "s,LDFLAGS = -s #-g #-static -p,LDFLAGS = -L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib," Makefile)
	cat $(NOTIFY_PATCH) | patch -d $(FWLOGWATCH_DIR) -p1
	touch $(FWLOGWATCH_DIR)/.configured

$(FWLOGWATCH_DIR)/.build: $(FWLOGWATCH_DIR)/.configured
	make CC=$(TARGET_CC) $(MAKEOPTS) -C $(FWLOGWATCH_DIR)
	mkdir -p $(FWLOGWATCH_TARGET_DIR)
	mkdir -p $(FWLOGWATCH_TARGET_DIR)/usr/bin
	mkdir -p $(FWLOGWATCH_TARGET_DIR)/etc/fwlogwatch
	mkdir -p $(FWLOGWATCH_TARGET_DIR)/etc/default
	mkdir -p $(FWLOGWATCH_TARGET_DIR)/etc/init.d
	mkdir -p $(FWLOGWATCH_TARGET_DIR)/etc/cron.daily
	mkdir -p $(FWLOGWATCH_TARGET_DIR)/var/webconf/www
	cp $(FWLOGWATCH_DIR)/fwlogwatch $(FWLOGWATCH_TARGET_DIR)/usr/bin
	cp $(FWLOGWATCH_DIR)/fwlogwatch.config $(FWLOGWATCH_TARGET_DIR)/etc/fwlogwatch
	cp $(FWLOGWATCH_DIR)/contrib/fwlogsummary_small.cgi $(FWLOGWATCH_TARGET_DIR)/var/webconf/www
	cp $(FWLOGWATCH_DIR)/contrib/fwlw_notify $(FWLOGWATCH_TARGET_DIR)/etc/fwlogwatch
	cp $(FWLOGWATCH_DIR)/contrib/fwlw_respond $(FWLOGWATCH_TARGET_DIR)/etc/fwlogwatch
	cp -aL fwlogwatch.init $(FWLOGWATCH_TARGET_DIR)/etc/init.d/fwlogwatch
	cp -aL fwlogwatch.default $(FWLOGWATCH_TARGET_DIR)/etc/default/fwlogwatch
	cp -aL fwlogwatch.cron $(FWLOGWATCH_TARGET_DIR)/etc/cron.daily/fwlogwatch
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(FWLOGWATCH_TARGET_DIR)/usr/bin/*
	cp -a $(FWLOGWATCH_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(FWLOGWATCH_DIR)/.build

build: $(FWLOGWATCH_DIR)/.build

clean:
	make -C $(FWLOGWATCH_DIR) clean
	rm -rf $(FWLOGWATCH_TARGET_DIR)
	rm -f $(FWLOGWATCH_DIR)/.build
	rm -f $(FWLOGWATCH_DIR)/.configured

srcclean: clean
	rm -rf $(FWLOGWATCH_DIR)
	rm -f .source
