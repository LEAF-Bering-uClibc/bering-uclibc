#############################################################
#
# iproute
#
# $Id: buildtool.mk,v 1.6 2010/12/10 13:33:51 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
IPROUTE_DIR:=iproute2-2.6.35
IPROUTE_TARGET_DIR:=$(BT_BUILD_DIR)/iproute2


$(IPROUTE_DIR)/.source: 
	bzcat $(IPROUTE_SOURCE) |  tar -xvf - 
	cat $(IPROUTE_PATCH1) | patch -d $(IPROUTE_DIR) -p1
	zcat $(IPROUTE_PATCH2) | patch -d $(IPROUTE_DIR) -p1
	cat $(IPROUTE_PATCH3) | patch -d $(IPROUTE_DIR) -p1
	touch $(IPROUTE_DIR)/.source

$(IPROUTE_DIR)/.configured: 
	(cd $(IPROUTE_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS=$(CFLAGS) \
	./configure)
	touch $(IPROUTE_DIR)/.configured

$(IPROUTE_DIR)/.build: $(IPROUTE_DIR)/.source
	mkdir -p $(IPROUTE_TARGET_DIR)
	mkdir -p $(IPROUTE_TARGET_DIR)/sbin
	mkdir -p $(IPROUTE_TARGET_DIR)/etc/iproute2
	$(MAKE) KERNEL_INCLUDE=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/include  \
		LIBC_INCLUDE=$(BT_STAGING_DIR)/include \
		CC=$(TARGET_CC) \
		CCOPTS="-D_GNU_SOURCE $(BT_COPT_FLAGS) -Wstrict-prototypes -Wall " \
		-C $(IPROUTE_DIR) 
	cp -a  $(IPROUTE_DIR)/ip/ip $(IPROUTE_TARGET_DIR)/sbin
	cp -a  $(IPROUTE_DIR)/tc/tc $(IPROUTE_TARGET_DIR)/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPROUTE_TARGET_DIR)/sbin/*
	cp -a  $(IPROUTE_DIR)/etc/iproute2/* $(IPROUTE_TARGET_DIR)/etc/iproute2	
	cp -a $(IPROUTE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IPROUTE_DIR)/.build

source: $(IPROUTE_DIR)/.source $(IPROUTE_DIR)/.configured

build: $(IPROUTE_DIR)/.build

clean:
	-rm $(IPROUTE_DIR)/.build
	-$(MAKE) -C $(IPROUTE_DIR) clean
  
srcclean:
	rm -rf $(IPROUTE_DIR)
