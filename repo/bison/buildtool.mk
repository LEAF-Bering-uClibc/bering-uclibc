#############################################################
#
# bison
#
# # $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:35 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
BISON_DIR:=bison-1.875a
BISON_TARGET_DIR:=$(BT_STAGING_DIR)/usr
CFLAGS  = -Os -Wall


$(BISON_DIR)/.source: 
	zcat $(BISON_SOURCE) |  tar -xvf - 
	zcat $(BISON_PATCH1) | patch -d $(BISON_DIR) -p1
	touch $(BISON_DIR)/.source

$(BISON_DIR)/.configured: $(BISON_DIR)/.source
	(cd $(BISON_DIR); \
		CFLAGS="-Os -Wall" CC=$(TARGET_CC) LDFLAGS="-s"  \
		./configure  --prefix=$(BISON_TARGET_DIR) );
	touch $(BISON_DIR)/.configured

$(BISON_DIR)/.build: $(BISON_DIR)/.configured
	$(MAKE) -C $(BISON_DIR) CFLAGS="-Os -Wall" CC=$(TARGET_CC) LDFLAGS="-s"
	$(MAKE) -C $(BISON_DIR) install	
	#-rm $(BISON_TARGET_DIR)/bin/yacc	
	touch $(BISON_DIR)/.build

source: $(BISON_DIR)/.source 

build: $(BISON_DIR)/.build

clean:
	-rm $(BISON_DIR)/.build
	$(MAKE) -C $(BISON_DIR) clean
	-rm $(BISON_TARGET_DIR)/bin/bison		
	-rm $(BISON_TARGET_DIR)/bin/yacc

srcclean:
	rm -rf $(BISON_DIR)
