# makefile for perl

PERL_DIR:=perl-$(PERL_VER)
PERL_TARGET_DIR:=$(BT_BUILD_DIR)/perl

unexport LDFLAGS

$(PERL_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(PERL_SOURCE)
	$(BT_SETUP_BUILDDIR) -v --no-rmdir $(PERL_CROSS_SOURCE)
	touch $(PERL_DIR)/.source

source: $(PERL_DIR)/.source

$(PERL_DIR)/.configured: $(PERL_DIR)/.source
	( cd $(PERL_DIR) ; \
	./configure --prefix=/usr --target=$(GNU_TARGET_NAME) --host=$(GNU_HOST_NAME) \
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
	mkdir -p $(PERL_TARGET_DIR)/usr/include/perl5/CORE
	mkdir -p $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)
	mkdir -p $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)/Sys


# Build in single thread - -jN failed
	$(MAKE) -C $(PERL_DIR)
	(cd $(PERL_DIR); $(MAKE) ext/Sys-Hostname )
	cp -af  $(PERL_DIR)/perl $(PERL_TARGET_DIR)/usr/bin/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PERL_TARGET_DIR)/usr/bin/*
	cp -af  $(PERL_DIR)/lib/* $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)/
	cp -af  $(PERL_DIR)/ext/Sys-Hostname/Hostname.pm $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)/Sys

	cp -af  $(PERL_DIR)/*.h $(PERL_TARGET_DIR)/usr/include/perl5/CORE/
	cp -afL $(PERL_SOCKET6_PM) $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)/
	cp -afL $(PERL_TEMP_PM) $(PERL_TARGET_DIR)/usr/lib/perl5/$(PERL_VER)/File/
	cp -af  $(PERL_TARGET_DIR)/* $(BT_STAGING_DIR)/
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
