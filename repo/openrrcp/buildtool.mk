#############################################################
#
# iproute
#
#############################################################

OPENRRCP_DIR:=openrrcp-0.2.1
OPENRRCP_TARGET_DIR:=$(BT_BUILD_DIR)/openrrcp


source: $(OPENRRCP_DIR)/Makefile

$(OPENRRCP_DIR)/Makefile:
	zcat $(SOURCE) |  tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(OPENRRCP_DIR)

build: $(OPENRRCP_DIR)/Makefile
	mkdir -p $(OPENRRCP_TARGET_DIR)
	mkdir -p $(OPENRRCP_TARGET_DIR)/usr
	mkdir -p $(OPENRRCP_TARGET_DIR)/usr/bin
	$(MAKE) KERNEL_INCLUDE=$(BT_LINUX_DIR)/include  \
		LIBC_INCLUDE=$(BT_STAGING_DIR)/include \
		CC=$(TARGET_CC) \
		CCOPTS="-D_GNU_SOURCE $(CFLAGS) -Wstrict-prototypes -Wall " \
		$(MAKEOPTS) \
		-C $(OPENRRCP_DIR)

	cp -a  $(OPENRRCP_DIR)/bin/* $(OPENRRCP_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENRRCP_TARGET_DIR)/usr/bin/*
	cp -a $(OPENRRCP_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	-rm -f $(OPENRRCP_DIR)/bin/*

srcclean:
	rm -rf $(OPENRRCP_DIR)
