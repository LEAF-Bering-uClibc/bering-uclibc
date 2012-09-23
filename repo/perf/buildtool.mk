include $(MASTERMAKEFILE)

DIR=perf
SRCDIR=$(BT_LINUX_DIR)/tools/perf
TARGET_DIR=$(BT_BUILD_DIR)/perf

$(DIR)/.source:
	mkdir -p $(DIR)
	touch $(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(TARGET_DIR)
	(OUTPUT=../../../../perf/perf/ NO_PERL=1 NO_LIBPERL=1 \
	NO_LIBPYTHON=1 NO_CURL=1 NO_ICONV=1 NO_DWARF=1 \
	CC=$(TARGET_CC) EXTRA_CFLAGS="$(CFLAGS)" \
	make $(MAKEOPTS) DESTDIR=$(TARGET_DIR)/usr -C $(SRCDIR) install)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-rm -rf $(TARGET_DIR)/usr/libexec
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

source: $(DIR)/.source

build: $(DIR)/.build

clean:
	rm -rf $(DIR)/*

srcclean:
	rm -rf $(DIR)
