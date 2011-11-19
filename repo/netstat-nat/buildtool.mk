# makefile for netstat-nat
include $(MASTERMAKEFILE)

NETSTAT_NAT_DIR:=netstat-nat-1.4.7
NETSTAT_NAT_TARGET_DIR:=$(BT_BUILD_DIR)/netstat-nat

$(NETSTAT_NAT_DIR)/.source:
	zcat $(NETSTAT_NAT_SOURCE) | tar -xvf -
	touch $(NETSTAT_NAT_DIR)/.source

source: $(NETSTAT_NAT_DIR)/.source

$(NETSTAT_NAT_DIR)/.configured: $(NETSTAT_NAT_DIR)/.source
	(cd $(NETSTAT_NAT_DIR) ; ./configure \
		--prefix=/usr \
		--host=$(GNU_TARGET_NAME) \
	)
	touch $(NETSTAT_NAT_DIR)/.configured

$(NETSTAT_NAT_DIR)/.build: $(NETSTAT_NAT_DIR)/.configured
	mkdir -p $(NETSTAT_NAT_TARGET_DIR)
	mkdir -p $(NETSTAT_NAT_TARGET_DIR)/usr/bin
	make $(MAKEOPTS) -C $(NETSTAT_NAT_DIR)
	cp -a $(NETSTAT_NAT_DIR)/netstat-nat $(NETSTAT_NAT_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(NETSTAT_NAT_TARGET_DIR)/usr/bin/*
	cp -a $(NETSTAT_NAT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(NETSTAT_NAT_DIR)/.build

build: $(NETSTAT_NAT_DIR)/.build
                                                                                         
clean:
	make -C $(NETSTAT_NAT_DIR) clean
	rm -rf $(NETSTAT_NAT_TARGET_DIR)
	rm -f $(NETSTAT_NAT_DIR)/.build
	rm -f $(NETSTAT_NAT_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(NETSTAT_NAT_DIR) 
	rm -f $(NETSTAT_NAT_DIR)/.source
