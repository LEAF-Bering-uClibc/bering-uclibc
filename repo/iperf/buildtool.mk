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
	(cd $(IPERF_DIR) ; ./configure --prefix=/usr \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME))
	touch $(IPERF_DIR)/.configured

$(IPERF_DIR)/.build: $(IPERF_DIR)/.configured
	mkdir -p $(IPERF_TARGET_DIR)
	mkdir -p $(IPERF_TARGET_DIR)/usr/bin
	$(MAKE) $(MAKEOPTS) -C $(IPERF_DIR)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPERF_DIR)/src/iperf
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
