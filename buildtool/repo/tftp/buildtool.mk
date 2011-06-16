# makefile for tftp
include $(MASTERMAKEFILE)

TFTP_DIR:=tftp-hpa-0.41
TFTP_TARGET_DIR:=$(BT_BUILD_DIR)/tftp

TFTP_LIBS = -liberty
TFTPD_LIBS = -lwrap -liberty

$(TFTP_DIR)/.source:
	zcat $(TFTP_SOURCE) | tar -xvf -
	touch $(TFTP_DIR)/.source

source: $(TFTP_DIR)/.source
                        
$(TFTP_DIR)/.configured: $(TFTP_DIR)/.source
	(cd $(TFTP_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" ./configure --prefix=/usr --without-readline )
	touch $(TFTP_DIR)/.configured
                                                                 
$(TFTP_DIR)/.build: $(TFTP_DIR)/.configured
	mkdir -p $(TFTP_TARGET_DIR)
	mkdir -p $(TFTP_TARGET_DIR)/usr/sbin	
	mkdir -p $(TFTP_TARGET_DIR)/usr/bin		
	make -C $(TFTP_DIR) TFTP_LIBS="$(TFTP_LIBS)" TFTPD_LIBS="$(TFTPD_LIBS)"
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(TFTP_DIR)/tftpd/tftpd
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(TFTP_DIR)/tftp/tftp
	cp -a $(TFTP_DIR)/tftpd/tftpd $(TFTP_TARGET_DIR)/usr/sbin/in.tftpd
	cp -a $(TFTP_DIR)/tftp/tftp $(TFTP_TARGET_DIR)/usr/bin
	cp -a $(TFTP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(TFTP_DIR)/.build

build: $(TFTP_DIR)/.build
                                                                                         
clean:
	make -C $(TFTP_DIR) clean
	rm -rf $(TFTP_TARGET_DIR)
	rm -rf $(TFTP_DIR)/.build
	rm -rf $(TFTP_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(TFTP_DIR) 
	rm -rf $(TFTP_DIR)/.source
