# makefile for snarf
include $(MASTERMAKEFILE)

SNARF_DIR:=snarf-7.0.orig
SNARF_TARGET_DIR:=$(BT_BUILD_DIR)/snarf

export CFLAGS := $(BT_COPT_FLAGS) -Wall

$(SNARF_DIR)/.source:
	zcat $(SNARF_SOURCE) | tar -xvf -
	zcat $(SNARF_PATCH) | patch -d $(SNARF_DIR) -p1
	touch $(SNARF_DIR)/.source

source: $(SNARF_DIR)/.source

$(SNARF_DIR)/.configured: $(SNARF_DIR)/.source
	(cd $(SNARF_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) ./configure --prefix=/usr --with-guess-winsize)
	touch $(SNARF_DIR)/.configured

$(SNARF_DIR)/.build: $(SNARF_DIR)/.configured
	mkdir -p $(SNARF_TARGET_DIR)
	mkdir -p $(SNARF_TARGET_DIR)/usr/bin
	make CC=$(TARGET_CC) -C $(SNARF_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SNARF_DIR)/snarf
	cp -a $(SNARF_DIR)/snarf $(SNARF_TARGET_DIR)/usr/bin
	cp -a $(SNARF_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SNARF_DIR)/.build

build: $(SNARF_DIR)/.build

clean:
	make -C $(SNARF_DIR) clean
	rm -rf $(SNARF_TARGET_DIR)
	rm -f $(SNARF_DIR)/.build
	rm -f $(SNARF_DIR)/.configured

srcclean: clean
	rm -rf $(SNARF_DIR)
	rm -f $(SNARF_DIR)/.source
