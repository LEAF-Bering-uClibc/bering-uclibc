# makefile for procps

PROCPS_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(PROCPS_SOURCE) 2>/dev/null )
PROCPS_TARGET_DIR:=$(BT_BUILD_DIR)/procps

$(PROCPS_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(PROCPS_SOURCE)
	cat $(PS_PATCH) | patch -p1 -d $(PROCPS_DIR)
	touch $(PROCPS_DIR)/.source

source: $(PROCPS_DIR)/.source

$(PROCPS_DIR)/.build: source
	mkdir -p $(PROCPS_TARGET_DIR)
	$(MAKE) -C $(PROCPS_DIR) CC=$(TARGET_CC) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C $(PROCPS_DIR) install DESTDIR=$(PROCPS_TARGET_DIR)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PROCPS_TARGET_DIR)/lib/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PROCPS_TARGET_DIR)/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PROCPS_TARGET_DIR)/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PROCPS_TARGET_DIR)/usr/bin/*
	cp -fd "$(PROCPS_TARGET_DIR)"/lib/libproc-*    "$(BT_STAGING_DIR)"/lib/
	cp -fd "$(PROCPS_TARGET_DIR)"/bin/kill         "$(BT_STAGING_DIR)"/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/bin/ps           "$(BT_STAGING_DIR)"/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/sbin/sysctl      "$(BT_STAGING_DIR)"/sbin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/free     "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/pgrep    "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/pkill    "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/pmap     "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/pwdx     "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/skill    "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/slabtop  "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/snice    "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/tload    "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/top      "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/uptime   "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/vmstat   "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/w        "$(BT_STAGING_DIR)"/usr/bin/
	cp -fd "$(PROCPS_TARGET_DIR)"/usr/bin/watch    "$(BT_STAGING_DIR)"/usr/bin/
	touch $(PROCPS_DIR)/.build

build: $(PROCPS_DIR)/.build

clean:
	make -C $(PROCPS_DIR) clean
	rm -rf $(PROCPS_TARGET_DIR)
	-rm $(PROCPS_DIR)/.build

srcclean: clean
	rm -rf $(PROCPS_DIR)
