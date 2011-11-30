#############################################################
#
# flex
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:02:26 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
FLEX_DIR=$(shell echo $(FLEX_SOURCE) | sed 's/\.\(tar\.\|\t\)\(gz\|bz2\)//')
FLEX_TARGET_DIR=$(BT_BUILD_DIR)/flex

$(FLEX_DIR)/.source:
	bzcat $(FLEX_SOURCE) |  tar -xvf -
	touch $(FLEX_DIR)/.source

$(FLEX_DIR)/.configured: $(FLEX_DIR)/.source
	(cd $(FLEX_DIR); \
		./configure --verbose --prefix=/usr --host=$(GNU_TARGET_NAME));
	touch $(FLEX_DIR)/.configured

$(FLEX_DIR)/.build: $(FLEX_DIR)/.configured
	mkdir -p $(FLEX_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(FLEX_DIR)
	#don't fail on errors in check
	-$(MAKE) $(MAKEOPTS) -C $(FLEX_DIR) check
	$(MAKE) $(MAKEOPTS) -C $(FLEX_DIR) DESTDIR=$(FLEX_TARGET_DIR) install
	rm -rf $(FLEX_TARGET_DIR)/usr/info $(FLEX_TARGET_DIR)/usr/man $(FLEX_TARGET_DIR)/usr/bin
	cp -a $(FLEX_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(FLEX_DIR)/.build

source: $(FLEX_DIR)/.source

build: $(FLEX_DIR)/.build

clean:
	-rm $(FLEX_DIR)/.build
	-$(MAKE) -C $(FLEX_DIR) clean
	-rm -rf $(FLEX_TARGET_DIR)

srcclean:
	-rm -rf $(FLEX_DIR)
