# makefile for mgetty
include $(MASTERMAKEFILE)

MGETTY_DIR:=mgetty-1.1.30
MGETTY_TARGET_DIR:=$(BT_BUILD_DIR)/mgetty

patchdir = $(MGETTY_DIR)/debian/patches
patches = $(shell ls $(patchdir) | sort)
rev_patches = $(shell ls $(patchdir) | sort -r)


$(MGETTY_DIR)/.source:
	zcat $(MGETTY_SOURCE) | tar -xvf -
	zcat $(MGETTY_PATCH) | patch -d $(MGETTY_DIR) -p1
	touch $(MGETTY_DIR)/.source

source: $(MGETTY_DIR)/.source

$(MGETTY_DIR)/.build: $(MGETTY_DIR)/.source

	cd $(MGETTY_DIR)/
	@for file in $(patches); do \
	if [ ! -f $(patchdir)/$$file.stamp ]; then \
		echo Applying $$file...; \
		cat $(patchdir)/$$file | patch -d $(MGETTY_DIR) -p1; \
		touch $(patchdir)/$$file.stamp; \
	fi; \
	done

	-cp $(MGETTY_DIR)/debian/policy.h $(MGETTY_DIR)/debian/voice-defs.h $(MGETTY_DIR)

	mkdir -p $(MGETTY_TARGET_DIR)
	mkdir -p $(MGETTY_TARGET_DIR)/etc/
	mkdir -p $(MGETTY_TARGET_DIR)/etc/mgetty
	mkdir -p $(MGETTY_TARGET_DIR)/etc/cron.daily
	mkdir -p $(MGETTY_TARGET_DIR)/sbin
	mkdir -p $(MGETTY_TARGET_DIR)/usr/sbin
	mkdir -p $(MGETTY_TARGET_DIR)/usr/bin
#build in single thread
	make CFLAGSS="-pipe -DAUTO_PPP -DFIFO" \
	SHELL=/bin/sh -C $(MGETTY_DIR) sedscript
	make CC=$(TARGET_CC) CFLAGS="$(CFLAGS) -pipe -DAUTO_PPP -DFIFO" \
	SHELL=/bin/sh -C $(MGETTY_DIR) bin-all
	cp -aL issue.mgetty $(MGETTY_TARGET_DIR)/etc
	cp -aL mgetty.cron_daily $(MGETTY_TARGET_DIR)/etc/cron.daily/mgetty
	cp -aL login.config $(MGETTY_TARGET_DIR)/etc/mgetty
	cp -aL dialin.config $(MGETTY_TARGET_DIR)/etc/mgetty
	cp -aL mgetty.config $(MGETTY_TARGET_DIR)/etc/mgetty
	cp -a $(MGETTY_DIR)/mgetty $(MGETTY_TARGET_DIR)/sbin
	cp -a $(MGETTY_DIR)/newslock $(MGETTY_TARGET_DIR)/usr/bin
	cp -a $(MGETTY_DIR)/callback/callback $(MGETTY_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MGETTY_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MGETTY_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MGETTY_TARGET_DIR)/sbin/*
	cp -a $(MGETTY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(MGETTY_DIR)/.build

build: $(MGETTY_DIR)/.build

clean:
	make -C $(MGETTY_DIR) clean
	rm -rf $(MGETTY_TARGET_DIR)
	rm -rf $(MGETTY_DIR)/.build
	rm -rf $(MGETTY_DIR)/.configured

srcclean: clean
	rm -rf $(MGETTY_DIR)
	rm -rf $(MGETTY_DIR)/.source
