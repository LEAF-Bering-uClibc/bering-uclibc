######################################
#
# buildtool make file for tcpdump
#
######################################

include $(MASTERMAKEFILE)

TCPDUMP_DIR:=tcpdump-4.1.1
TCPDUMP_TARGET_DIR:=$(BT_BUILD_DIR)/tcpdump


$(TCPDUMP_DIR)/.source:
	zcat $(TCPDUMP_SOURCE) | tar -xvf -
#	zcat $(TCPDUMP_PATCH) | patch -d $(TCPDUMP_DIR) -p1
	touch $(TCPDUMP_DIR)/.source	

source: $(TCPDUMP_DIR)/.source


$(TCPDUMP_DIR)/.configured: $(TCPDUMP_DIR)/.source
	(cd $(TCPDUMP_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure --prefix=/usr \
	--without-crypto \
	--enable-ipv6 \
	--disable-smb )
	perl -i -p -e "s,-I/usr,-I/$(BT_STAGING_DIR)/usr,g;" $(TCPDUMP_DIR)/Makefile
	perl -i -p -e "s,-L/usr,-L/$(BT_STAGING_DIR)/usr,g;" $(TCPDUMP_DIR)/Makefile
	touch $(TCPDUMP_DIR)/.configured


$(TCPDUMP_DIR)/.build: $(TCPDUMP_DIR)/.configured
	mkdir -p $(TCPDUMP_TARGET_DIR)
	make -C $(TCPDUMP_DIR) CC=$(TARGET_CC) LD=$(TARGET_LD) CCOPT="$(BT_COPT_FLAGS)"
	make -C $(TCPDUMP_DIR) DESTDIR=$(TCPDUMP_TARGET_DIR) install
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TCPDUMP_TARGET_DIR)/usr/sbin/*
	cp -a $(TCPDUMP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TCPDUMP_DIR)/.build


build: $(TCPDUMP_DIR)/.build


clean:
	make -C $(TCPDUMP_DIR) clean
	rm -rf $(TCPDUMP_TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/sbin/tcpdump
	rm -f $(TCPDUMP_DIR)/.build
	rm -f $(TCPDUMP_DIR)/.configured


srcclean: clean
	rm -rf $(TCPDUMP_DIR)
	rm -f $(TCPDUMP_DIR)/.source

