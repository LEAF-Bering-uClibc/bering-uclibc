#############################################################
#
# iperf
#
#############################################################

include $(MASTERMAKEFILE)
IPERF_DIR:=iperf-2.0.5
IPERF_TARGET_DIR:=$(BT_BUILD_DIR)/iperf
#export AUTOCONF=$(BT_STAGING_DIR)/bin/autoconf
export AUTOCONF=/bin/true

$(IPERF_DIR)/.source:
	zcat $(IPERF_SOURCE) |  tar -xvf -
	# zcat $(IPERF_PATCH1) | patch -d $(IPERF_DIR) -p1
	# zcat $(IPERF_PATCH2) | patch -d $(IPERF_DIR) -p1
	touch $(IPERF_DIR)/.source

$(IPERF_DIR)/.configured: $(IPERF_DIR)/.source
	(cd $(IPERF_DIR) ; $(AUTOCONF) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS) \
    -I$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/include" \
    LDFLAGS="-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib" \
    ./configure --prefix=/usr )
	touch $(IPERF_DIR)/.configured

$(IPERF_DIR)/.build: $(IPERF_DIR)/.configured
	mkdir -p $(IPERF_TARGET_DIR)
	mkdir -p $(IPERF_TARGET_DIR)/usr/bin
	$(MAKE) -C $(IPERF_DIR) CC=$(TARGET_CC) CFLAGS="-Wall $(BT_COPT_FLAGS)"
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(IPERF_DIR)/src/iperf
	cp -a $(IPERF_DIR)/src/iperf $(IPERF_TARGET_DIR)/usr/bin/iperf
	cp -a $(IPERF_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IPERF_DIR)/.build

source: $(IPERF_DIR)/.source

build: $(IPERF_DIR)/.build

clean:
	-rm $(IPERF_DIR)/.build
	$(MAKE) -C $(IPERF_DIR) clean
	-rm $(IPERF_DIR)/.configured

srcclean:
	rm -rf $(IPERF_DIR)
