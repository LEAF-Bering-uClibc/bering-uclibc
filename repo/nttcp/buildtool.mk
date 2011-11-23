#############################################################
#
# nttcp
#
#############################################################

include $(MASTERMAKEFILE)
NTTCP_DIR:=nttcp-1.47
NTTCP_TARGET_DIR:=$(BT_BUILD_DIR)/nttcp
NTTCP_FLAGS=-Os
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment


$(NTTCP_DIR)/.source:
	zcat $(NTTCP_SOURCE) | tar -xvf -
	perl -i -p -e 's,^ARCH\s*=,#ARCH\=,' $(NTTCP_DIR)/Makefile
	perl -i -p -e 's,^LIB\s*=,#LIB\=,' $(NTTCP_DIR)/Makefile
	perl -i -p -e 's,^OPT\s*=,#OPT=,' $(NTTCP_DIR)/Makefile
	perl -i -p -e 's,^CC\s*=,#CC=,' $(NTTCP_DIR)/Makefile
	perl -i -p -e 's,^DBG\s*=,#DBG=,' $(NTTCP_DIR)/Makefile
	perl -i -p -e 's,^INC\s*=,#INC=,' $(NTTCP_DIR)/Makefile
	perl -i -p -e 's,^prefix\s*=,#prefix=,' $(NTTCP_DIR)/Makefile


	touch $(NTTCP_DIR)/.source

source: $(NTTCP_DIR)/.source

build:
	-mkdir -p $(NTTCP_TARGET_DIR)
	-mkdir -p $(BT_STAGING_DIR)/usr/bin
	make CC=$(TARGET_CC) OPT="-Os" ARCH="" -C $(NTTCP_DIR)
	$(BT_STRIP) $(STRIP_OPTIONS) $(NTTCP_DIR)/nttcp
	make CC=$(TARGET_CC) prefix=$(NTTCP_TARGET_DIR) -C $(NTTCP_DIR) install
	cp $(NTTCP_DIR)/nttcp $(BT_STAGING_DIR)/usr/bin/

clean:
	make CC=$(TARGET_CC) -C $(NTTCP_DIR) clean
	rm -rf $(NTTCP_TARGET_DIR)

srcclean: clean
	rm -rf $(NTTCP_DIR)
	-rm $(NTTCP_DIR)/.source

