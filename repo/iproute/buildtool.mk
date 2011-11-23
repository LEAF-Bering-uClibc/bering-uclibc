#############################################################
#
# iproute2
#
# Warning! Makefile is too ugly, be warn on version update!
#
#############################################################

include $(MASTERMAKEFILE)
IPROUTE_DIR:=$(shell echo $(IPROUTE_SOURCE) | sed 's/\.\(tar\.\|\t\)\(gz\|bz2\)//')
IPROUTE_TARGET_DIR:=$(BT_BUILD_DIR)/iproute2

# Dirty hacks for iproute2-2.6.35
export LDLIBS = -L../lib -lnetlink -lutil
export CFLAGS += -D_GNU_SOURCE -I../include -DRESOLVE_HOSTNAMES
export CC = $(TARGET_CC)
export ADDLIB = dnet_ntop.o dnet_pton.o ipx_ntop.o ipx_pton.o
export YACCFLAGS = -d -t -v

$(IPROUTE_DIR)/.source:
	bzcat $(IPROUTE_SOURCE) |  tar -xvf -
	cat $(IPROUTE_PATCH1) | patch -d $(IPROUTE_DIR) -p1
	zcat $(IPROUTE_PATCH2) | patch -d $(IPROUTE_DIR) -p1
	echo "TC_CONFIG_XT=y" > $(IPROUTE_DIR)/Config
	touch $(IPROUTE_DIR)/.source

$(IPROUTE_DIR)/.build:
	mkdir -p $(IPROUTE_TARGET_DIR)/sbin
	mkdir -p $(IPROUTE_TARGET_DIR)/etc/iproute2
	make $(MAKEOPTS) -C $(IPROUTE_DIR)/lib
	make $(MAKEOPTS) -C $(IPROUTE_DIR)/ip ip
# tc should be assembled in single thread
	make -C $(IPROUTE_DIR)/tc libtc.a tc
	cp -a  $(IPROUTE_DIR)/ip/ip $(IPROUTE_TARGET_DIR)/sbin
	cp -a  $(IPROUTE_DIR)/tc/tc $(IPROUTE_TARGET_DIR)/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPROUTE_TARGET_DIR)/sbin/*
	cp -a  $(IPROUTE_DIR)/etc/iproute2/* $(IPROUTE_TARGET_DIR)/etc/iproute2
	cp -a $(IPROUTE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IPROUTE_DIR)/.build

source: $(IPROUTE_DIR)/.source

build: $(IPROUTE_DIR)/.build

clean:
	-rm $(IPROUTE_DIR)/.build
	-rm -rf $(IPROUTE_TARGET_DIR)
	-$(MAKE) -C $(IPROUTE_DIR) clean

srcclean:
	rm -rf $(IPROUTE_DIR)
