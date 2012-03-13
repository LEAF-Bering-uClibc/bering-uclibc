#############################################################
#
# libdigest-sha1-perl
#
#############################################################

include $(MASTERMAKEFILE)
LIBDIGEST-SHA1-PERL_DIR:=Digest-SHA1-2.13
LIBDIGEST-SHA1-PERL_TARGET_DIR:=$(BT_BUILD_DIR)/libdigest-sha1-perl
export CC=$(TARGET_CC)

$(LIBDIGEST-SHA1-PERL_DIR)/.source: 
	zcat $(LIBDIGEST-SHA1-PERL_SOURCE) | tar -xvf -
	touch $(LIBDIGEST-SHA1-PERL_DIR)/.source

source: $(LIBDIGEST-SHA1-PERL_DIR)/.source

$(LIBDIGEST-SHA1-PERL_DIR)/.build: $(LIBDIGEST-SHA1-PERL_DIR)/.source
	mkdir -p $(LIBDIGEST-SHA1-PERL_TARGET_DIR)
	mkdir -p $(LIBDIGEST-SHA1-PERL_TARGET_DIR)/usr/lib/perl5/5.14.2
	cd $(LIBDIGEST-SHA1-PERL_DIR); perl Makefile.PL; \
	$(MAKE);
	cp $(LIBDIGEST-SHA1-PERL_DIR)/SHA1.pm $(LIBDIGEST-SHA1-PERL_TARGET_DIR)/usr/lib/perl5/5.14.2
	cp $(LIBDIGEST-SHA1-PERL_DIR)/blib/arch/auto/Digest/SHA1/SHA1.so $(LIBDIGEST-SHA1-PERL_TARGET_DIR)/usr/lib/perl5/5.14.2
	
	cp -a $(LIBDIGEST-SHA1-PERL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBDIGEST-SHA1-PERL_DIR)/.build

build: $(LIBDIGEST-SHA1-PERL_DIR)/.build	

clean:
	rm -rf $(LIBDIGEST-SHA1-PERL_DIR)/.build
	rm -rf $(LIBDIGEST-SHA1-PERL_TARGET_DIR)

srcclean: clean
	rm -rf $(LIBDIGEST-SHA1-PERL_DIR)
