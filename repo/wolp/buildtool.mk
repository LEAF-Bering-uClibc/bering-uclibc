# makefile for wolp
include $(MASTERMAKEFILE)

WOLP_DIR:=wolp-0.5
WOLP_TARGET_DIR:=$(BT_BUILD_DIR)/wolp

$(WOLP_DIR)/.source:
	zcat $(WOLP_SOURCE) | tar -xvf -
	touch $(WOLP_DIR)/.source

source: $(WOLP_DIR)/.source

$(WOLP_DIR)/.build: $(WOLP_DIR)/.source
	mkdir -p $(WOLP_TARGET_DIR)
	mkdir -p $(WOLP_TARGET_DIR)/usr/sbin
	mkdir -p $(WOLP_TARGET_DIR)/etc
	make CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" -C $(WOLP_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(WOLP_DIR)/wold
	cp -a $(WOLP_DIR)/wold $(WOLP_TARGET_DIR)/usr/sbin
	cp -aL wolp.conf $(WOLP_TARGET_DIR)/etc
	cp -a $(WOLP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(WOLP_DIR)/.build

build: $(WOLP_DIR)/.build

clean:
	make -C $(WOLP_DIR) clean
	rm -rf $(WOLP_TARGET_DIR)
	rm -f $(WOLP_DIR)/.build

srcclean: clean
	rm -rf $(WOLP_DIR)
	rm -f $(WOLP_DIR)/.source
