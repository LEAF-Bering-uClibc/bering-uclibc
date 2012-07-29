#############################################################
#
# nttcp
#
#############################################################

include $(MASTERMAKEFILE)
NTTCP_DIR:=nttcp-1.47
NTTCP_TARGET_DIR:=$(BT_BUILD_DIR)/nttcp


$(NTTCP_DIR)/.source:
	zcat $(NTTCP_SOURCE) | tar -xvf -
	touch $(NTTCP_DIR)/.source

source: $(NTTCP_DIR)/.source

build:
	-mkdir -p $(NTTCP_TARGET_DIR)
	-mkdir -p $(BT_STAGING_DIR)/usr/bin
	make $(MAKEOPTS) CC=$(TARGET_CC) OPT="$(CFLAGS)" ARCH="" LIB="" \
		prefix=$(NTTCP_TARGET_DIR) -C $(NTTCP_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NTTCP_TARGET_DIR)/bin/*
	cp $(NTTCP_TARGET_DIR)/bin/* $(BT_STAGING_DIR)/usr/bin/

clean:
	make CC=$(TARGET_CC) -C $(NTTCP_DIR) clean
	rm -rf $(NTTCP_TARGET_DIR)

srcclean: clean
	rm -rf $(NTTCP_DIR)

