# makefile for elvis-tiny
include $(MASTERMAKEFILE)

ELVIS-TINY_DIR:=elvis-tiny-1.4.orig
ELVIS-TINY_TARGET_DIR:=$(BT_BUILD_DIR)/elvis-tiny

$(ELVIS-TINY_DIR)/.source:
	zcat $(ELVIS-TINY_SOURCE) | tar -xvf -
	zcat $(ELVIS-TINY_PATCH) | patch -d $(ELVIS-TINY_DIR) -p1
	touch $(ELVIS-TINY_DIR)/.source

source: $(ELVIS-TINY_DIR)/.source

$(ELVIS-TINY_DIR)/.build: $(ELVIS-TINY_DIR)/.source
	mkdir -p $(ELVIS-TINY_TARGET_DIR)
	mkdir -p $(ELVIS-TINY_TARGET_DIR)/bin
	make $(MAKEOPTS) CC=$(TARGET_CC) EXTRA_CFLAGS="$(CFLAGS) $(LDFLAGS) -fsigned-char" -C $(ELVIS-TINY_DIR)
	$(TARGET_CC) $(CFLAGS) -s -o $(ELVIS-TINY_DIR)/debian/wrapper $(ELVIS-TINY_DIR)/debian/wrapper.c
	cp -a $(ELVIS-TINY_DIR)/elvis $(ELVIS-TINY_TARGET_DIR)/bin/elvis-tiny
	cp -a $(ELVIS-TINY_DIR)/debian/wrapper $(ELVIS-TINY_TARGET_DIR)/bin/vi
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(ELVIS-TINY_TARGET_DIR)/bin/*
	cp -a $(ELVIS-TINY_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ELVIS-TINY_DIR)/.build

build: $(ELVIS-TINY_DIR)/.build

clean:
	-make -C $(ELVIS-TINY_DIR) clobber
	rm -f $(ELVIS-TINY_DIR)/.build debian/{files,substvars,wrapper}
	rm -rf $(tmp)
	find . -name '*.bak' -o name '*~' | xargs -r rm -f --
	rm -rf $(ELVIS-TINY_TARGET_DIR)


srcclean: clean
	rm -rf $(ELVIS-TINY_DIR)
