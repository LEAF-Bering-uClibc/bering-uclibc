# makefile for perl
include $(MASTERMAKEFILE)

PERL_VER:=5.14.2
PERL_DIR:=perl-$(PERL_VER)
PERL_TARGET_DIR:=$(BT_BUILD_DIR)/perl

unexport LDFLAGS

$(PERL_DIR)/.source:
	zcat $(PERL_SOURCE) | tar -xvf -
	zcat $(PERL_CROSS_SOURCE) | tar -xvf -
	touch $(PERL_DIR)/.source

source: $(PERL_DIR)/.source

$(PERL_DIR)/.configured: $(PERL_DIR)/.source
	( cd $(PERL_DIR) ; \
	./configure --prefix=/usr --target=$(GNU_TARGET_NAME) \
	-Dusethreads \
	-Dccflags="$(CFLAGS)")
	touch $(PERL_DIR)/.configured
#	--sysroot=$(BT_STAGING_DIR) \
#	-Ud_eaccess \
#	-Dlibc="$(BT_STAGING_DIR)/lib/libc.so.0" \
#	-Dcc=$(TARGET_CC) \

$(PERL_DIR)/.build: $(PERL_DIR)/.configured
	mkdir -p $(PERL_TARGET_DIR)
	mkdir -p $(PERL_TARGET_DIR)/usr/bin
	mkdir -p $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)

# Build in single thread - -jN failed
	$(MAKE) -C $(PERL_DIR)
	cp -a $(PERL_DIR)/perl $(PERL_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PERL_TARGET_DIR)/usr/bin/*
	cp -a $(PERL_DIR)/lib/* $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)
	cp -aL Socket6.pm $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)
	cp -aL Temp.pm $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)/File
	cp -a $(PERL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PERL_DIR)/.build

build: $(PERL_DIR)/.build

clean:
	-$(MAKE) -C $(PERL_DIR) clean
	rm -rf $(PERL_TARGET_DIR)
	rm -f $(PERL_DIR)/.build
	rm -rf $(BT_STAGING_DIR)/usr/lib/perl5/$(PERL_VER)
	rm -rf $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)
# this is probably not enough?
	rm -f $(PERL_DIR)/.configured

srcclean: clean
	rm -f $(PERL_DIR)/.source
	rm -rf $(PERL_DIR)
