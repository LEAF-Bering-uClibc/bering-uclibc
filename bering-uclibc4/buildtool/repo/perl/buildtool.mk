# makefile for perl
include $(MASTERMAKEFILE)

PERL_DIR:=perl-5.12.1
PERL_TARGET_DIR:=$(BT_BUILD_DIR)/perl
#PREG_STAGING_DIR=$(shell echo $(BT_STAGING_DIR)|sed 's/\//\\\//g')

$(PERL_DIR)/.source:
	bzcat $(PERL_SOURCE) | tar -xvf -
	mv $(PERL_DIR)/Configure $(PERL_DIR)/Configure.orig
	mv $(PERL_DIR)/hints/linux.sh $(PERL_DIR)/hints/linux.sh.orig
	sed 's:\([="'\'' ]\+\)\(\$$incpath\)\?\(/usr\|/usr/local\)\?/lib:\1$(BT_STAGING_DIR)\2\3/lib:g;'\
	's/fstack/fno-stack/g;' \
	$(PERL_DIR)/Configure.orig >$(PERL_DIR)/Configure
	sed 's:\([="'\'' ]\+\)\(\$$incpath\)\?\(/usr\|/usr/local\)\?/lib:\1$(BT_STAGING_DIR)\2\3/lib:g;' \
	$(PERL_DIR)/hints/linux.sh.orig >$(PERL_DIR)/hints/linux.sh
	chmod +x $(PERL_DIR)/Configure
	touch $(PERL_DIR)/.source

source: $(PERL_DIR)/.source

$(PERL_DIR)/.configured: $(PERL_DIR)/.source
	( cd $(PERL_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	CFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib $(BT_COPT_FLAGS) \
	-g -Wall" ./Configure -de -Dprefix=/usr -Dlibc="$(BT_STAGING_DIR)/lib/libc.so.0" \
	-Ud_eaccess -Ucc=$$CC)
	touch $(PERL_DIR)/.configured

$(PERL_DIR)/.build: $(PERL_DIR)/.configured
	mkdir -p $(PERL_TARGET_DIR)
	mkdir -p $(PERL_TARGET_DIR)/usr/bin
	mkdir -p $(PERL_TARGET_DIR)/usr/lib/perl5/5.12.1

	$(MAKE) CC=$(TARGET_CC) -C $(PERL_DIR)
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PERL_DIR)/perl
	cp -a $(PERL_DIR)/perl $(PERL_TARGET_DIR)/usr/bin
	cp -a $(PERL_DIR)/lib/* $(PERL_TARGET_DIR)/usr/lib/perl5/5.12.1
	cp -a $(PERL_DIR)/../Socket6.pm $(PERL_TARGET_DIR)/usr/lib/perl5/5.12.1
	cp -a $(PERL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PERL_DIR)/.build

build: $(PERL_DIR)/.build
                                                                                         
clean:
	-$(MAKE) -C $(PERL_DIR) clean
	rm -rf $(PERL_TARGET_DIR)
	rm -f $(PERL_DIR)/.build
	rm -rf $(BT_STAGING_DIR)/usr/lib/perl5/5.12.1
	rm -rf $(PERL_TARGET_DIR)/usr/lib/perl5/5.12.1
# this is probably not enough?	
	rm -f $(PERL_DIR)/.configured

                                                                                                                 
srcclean: clean
	rm -f $(PERL_DIR)/.source
	rm -rf $(PERL_DIR) 
