#############################################################
#
# debianutils
#
# $Id: buildtool.mk,v 1.2 2010/05/25 17:54:24 kapeka Exp $
#############################################################

include $(MASTERMAKEFILE)
DEBIANUTILS_DIR:= debianutils-2.8.1
DEBIANUTILS_TARGET_DIR:=$(BT_BUILD_DIR)/debianutils


$(DEBIANUTILS_DIR)/.source:
	zcat $(DEBIANUTILS_SOURCE) |  tar -xvf -
	#zcat $(DEBIANUTILS_PATCH1) | patch -d $(DEBIANUTILS_DIR) -p1
	touch $(DEBIANUTILS_DIR)/.source

$(DEBIANUTILS_DIR)/.configured: $(DEBIANUTILS_DIR)/.source
	cd $(DEBIANUTILS_DIR) && CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS) -Wall" ./configure --prefix=/
	cat defs.patch|patch -p1 -d $(DEBIANUTILS_DIR)
	touch $(DEBIANUTILS_DIR)/.configured

$(DEBIANUTILS_DIR)/.build: $(DEBIANUTILS_DIR)/.configured
	mkdir -p $(DEBIANUTILS_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/bin
	mkdir -p $(BT_STAGING_DIR)/sbin
	$(MAKE) -C $(DEBIANUTILS_DIR) CC=$(TARGET_CC)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DEBIANUTILS_DIR)/mktemp
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DEBIANUTILS_DIR)/tempfile
	$(MAKE) -C $(DEBIANUTILS_DIR) DESTDIR=$(DEBIANUTILS_TARGET_DIR) install
	rm -f $(DEBIANUTILS_TARGET_DIR)/bin/savelog
	rm -f $(DEBIANUTILS_TARGET_DIR)/bin/run-parts
	cp -a $(DEBIANUTILS_TARGET_DIR)/bin/* $(BT_STAGING_DIR)/bin/
	cp -a $(DEBIANUTILS_TARGET_DIR)/sbin/* $(BT_STAGING_DIR)/sbin/
	touch $(DEBIANUTILS_DIR)/.build

source: $(DEBIANUTILS_DIR)/.source

build: $(DEBIANUTILS_DIR)/.build

clean:
	-rm $(DEBIANUTILS_DIR)/.build
	-$(MAKE) -C $(DEBIANUTILS_DIR) clean

srcclean:
	rm -rf $(DEBIANUTILS_DIR)
