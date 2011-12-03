# makefile for daemontools
include $(MASTERMAKEFILE)

DAEMONTOOLS_DIR:=admin/daemontools-0.76
DAEMONTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/daemontools

$(DAEMONTOOLS_DIR)/.source:
	zcat $(DAEMONTOOLS_SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p2 -d $(DAEMONTOOLS_DIR)
	touch $(DAEMONTOOLS_DIR)/.source

source: $(DAEMONTOOLS_DIR)/.source

$(DAEMONTOOLS_DIR)/.configured: $(DAEMONTOOLS_DIR)/.source
# 	(cd $(DAEMONTOOLS_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure )
	echo "$(TARGET_CC) $(CFLAGS)" >$(DAEMONTOOLS_DIR)/src/conf-cc
	echo "$(TARGET_CC) $(LDFLAGS)" >$(DAEMONTOOLS_DIR)/src/conf-ld
	perl -i -p -e 's,\s+make\s+\), make $(MAKEOPTS) ),' $(DAEMONTOOLS_DIR)/package/compile
	perl -i -p -e 's,env\s+-\s+/bin/sh\s+rts.tests.*$$,touch rts,' $(DAEMONTOOLS_DIR)/src/Makefile
	perl -i -p -e 's,^\s*\./chkshsgr.*$$,,' $(DAEMONTOOLS_DIR)/src/Makefile
	touch $(DAEMONTOOLS_DIR)/.configured

$(DAEMONTOOLS_DIR)/.build: $(DAEMONTOOLS_DIR)/.configured
	cd $(DAEMONTOOLS_DIR)
	mkdir -p $(DAEMONTOOLS_TARGET_DIR)/usr/bin
	mkdir -p $(DAEMONTOOLS_TARGET_DIR)/etc/init.d
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
	(cd $(DAEMONTOOLS_DIR); package/compile );
	cp -a $(DAEMONTOOLS_DIR)/command/* $(DAEMONTOOLS_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DAEMONTOOLS_TARGET_DIR)/usr/bin/*
	chmod 755 $(DAEMONTOOLS_TARGET_DIR)/usr/bin/*
	cp -aL svscan $(DAEMONTOOLS_TARGET_DIR)/etc/init.d/
	cp -a $(DAEMONTOOLS_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DAEMONTOOLS_DIR)/.build

build: $(DAEMONTOOLS_DIR)/.build

clean:
	rm -rf $(DAEMONTOOLS_TARGET_DIR)
	-rm $(DAEMONTOOLS_DIR)/.build
	-rm $(DAEMONTOOLS_DIR)/.configured

srcclean: clean
	rm -rf $(DAEMONTOOLS_DIR)
