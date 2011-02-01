# makefile for perl
include $(MASTERMAKEFILE)

PERL_DIR:=perl-5.8.8
PERL_TARGET_DIR:=$(BT_BUILD_DIR)/perl

$(PERL_DIR)/.source:
	bzcat $(PERL_SOURCE) | tar -xvf -
	touch $(PERL_DIR)/.source

source: $(PERL_DIR)/.source

$(PERL_DIR)/.build: $(PERL_DIR)/.source
	mkdir -p $(PERL_TARGET_DIR)
	mkdir -p $(PERL_TARGET_DIR)/usr/bin
	$(MAKE) -f Makefile.micro CC=$(TARGET_CC) -C $(PERL_DIR)
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PERL_DIR)/microperl
	cp -a $(PERL_DIR)/microperl $(PERL_TARGET_DIR)/usr/bin
	cp -a $(PERL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PERL_DIR)/.build

build: $(PERL_DIR)/.build
                                                                                         
clean:
	-$(MAKE) -C $(PERL_DIR) clean
	rm -rf $(PERL_TARGET_DIR)
	rm -f $(PERL_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -f $(PERL_DIR)/.source
	rm -rf $(PERL_DIR) 
