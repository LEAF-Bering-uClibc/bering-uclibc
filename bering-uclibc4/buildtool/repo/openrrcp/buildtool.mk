#############################################################
#
# iproute
#
# $Id: buildtool.mk,v 1.5 2010/11/01 11:02:10 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
OPENRRCP_DIR:=openrrcp-0.2.1
OPENRRCP_TARGET_DIR:=$(BT_BUILD_DIR)/openrrcp


source: 
	zcat $(SOURCE) |  tar -xvf -

build: $(OPENRRCP_DIR)/Makefile
	mkdir -p $(OPENRRCP_TARGET_DIR)
	mkdir -p $(OPENRRCP_TARGET_DIR)/usr
	mkdir -p $(OPENRRCP_TARGET_DIR)/usr/bin
	$(MAKE) KERNEL_INCLUDE=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/include  \
		LIBC_INCLUDE=$(BT_STAGING_DIR)/include \
		CC=$(TARGET_CC) \
		CCOPTS="-D_GNU_SOURCE $(BT_COPT_FLAGS) -Wstrict-prototypes -Wall " \
		-C $(OPENRRCP_DIR) 
		
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENRRCP_DIR)/bin/rrcpcli
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENRRCP_DIR)/bin/rtl83xx
	cp -a  $(OPENRRCP_DIR)/bin/* $(OPENRRCP_TARGET_DIR)/usr/bin
	cp -a $(OPENRRCP_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	-rm -f $(OPENRRCP_DIR)/bin/*
 
srcclean:
	rm -rf $(OPENRRCP_DIR)