# makefile for tftp
include $(MASTERMAKEFILE)

TFTP_DIR:=tftp-hpa-0.41
TFTP_TARGET_DIR:=$(BT_BUILD_DIR)/tftp

$(TFTP_DIR)/.source:
	zcat $(TFTP_SOURCE) | tar -xvf -
	touch $(TFTP_DIR)/.source

source: $(TFTP_DIR)/.source

$(TFTP_DIR)/.configured: $(TFTP_DIR)/.source
	(cd $(TFTP_DIR) ; \
		./configure --prefix=/usr --without-readline --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	touch $(TFTP_DIR)/.configured

$(TFTP_DIR)/.build: $(TFTP_DIR)/.configured
	mkdir -p $(TFTP_TARGET_DIR)
	mkdir -p $(TFTP_TARGET_DIR)/usr/sbin
	mkdir -p $(TFTP_TARGET_DIR)/usr/bin
	make $(MAKEOPTS) -C $(TFTP_DIR)
	cp -a $(TFTP_DIR)/tftpd/tftpd $(TFTP_TARGET_DIR)/usr/sbin/in.tftpd
	cp -a $(TFTP_DIR)/tftp/tftp $(TFTP_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TFTP_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TFTP_TARGET_DIR)/usr/sbin/*
	cp -a $(TFTP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TFTP_DIR)/.build

build: $(TFTP_DIR)/.build

clean:
	make -C $(TFTP_DIR) clean
	rm -rf $(TFTP_TARGET_DIR)
	rm -f $(TFTP_DIR)/.build
	rm -f $(TFTP_DIR)/.configured

srcclean: clean
	rm -rf $(TFTP_DIR)
