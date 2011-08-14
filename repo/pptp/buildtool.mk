# makefile for pptp
include $(MASTERMAKEFILE)

PPTP_DIR:=pptp-1.7.1
PPTP_TARGET_DIR:=$(BT_BUILD_DIR)/pptp

$(PPTP_DIR)/.source:
	zcat $(PPTP_SOURCE) | tar -xvf -
	touch $(PPTP_DIR)/.source

source: $(PPTP_DIR)/.source

$(PPTP_DIR)/.build: $(PPTP_DIR)/.source
	mkdir -p $(PPTP_TARGET_DIR)
	mkdir -p $(PPTP_TARGET_DIR)/usr/sbin
	make CC=$(TARGET_CC) OPTIMIZE="$(BT_COPT_FLAGS)" -C $(PPTP_DIR)
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(PPTP_DIR)/pptp
	cp -a $(PPTP_DIR)/pptp $(PPTP_TARGET_DIR)/usr/sbin
	cp -a $(PPTP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PPTP_DIR)/.build

build: $(PPTP_DIR)/.build
                                                                                         
clean:
	make -C $(PPTP_DIR) clean
	rm -rf $(PPTP_TARGET_DIR)
	rm -f $(PPTP_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(PPTP_DIR) 