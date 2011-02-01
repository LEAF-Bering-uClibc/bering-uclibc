#############################################################
#
# flex
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:26 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
FLEX_DIR=flex-2.5.4
FLEX_TARGET_DIR=$(BT_STAGING_DIR)/usr

$(FLEX_DIR)/.source: 
	zcat $(FLEX_SOURCE) |  tar -xvf - 
	touch $(FLEX_DIR)/.source

$(FLEX_DIR)/.configured: $(FLEX_DIR)/.source
	(cd $(FLEX_DIR); \
		CFLAGS="-Os -Wall" CC=$(TARGET_CC) LDFLAGS="-s"  \
		./configure --verbose --prefix=$(FLEX_TARGET_DIR) );
	touch $(FLEX_DIR)/.configured

$(FLEX_DIR)/.build: $(FLEX_DIR)/.configured
	-mkdir -p $(FLEX_TARGET_DIR)/man/man1
	$(MAKE) -C $(FLEX_DIR) CFLAGS="-Os -Wall" CC=$(TARGET_CC) LDFLAGS="-s"
	$(MAKE) -C $(FLEX_DIR) check
	$(MAKE) -C $(FLEX_DIR) PREFIX="$(FLEX_TARGET_DIR)" install	
	touch $(FLEX_DIR)/.build

source: $(FLEX_DIR)/.source 

build: $(FLEX_DIR)/.build

clean:
	-rm $(FLEX_DIR)/.build
	$(MAKE) -C $(FLEX_DIR) clean
	-rm $(FLEX_TARGET_DIR)/man/man1/flex.1
	-rm $(FLEX_TARGET_DIR)/bin/flex
	-rm $(FLEX_TARGET_DIR)/bin/flex++
	-rm $(FLEX_TARGET_DIR)/lib/libfl.a
	-rm $(FLEX_TARGET_DIR)/include/FlexLexer.h
  
srcclean:
	rm -rf $(FLEX_DIR)
