# makefile for ser2net
include $(MASTERMAKEFILE)

SER2NET_DIR:=ser2net-2.3
SER2NET_TARGET_DIR:=$(BT_BUILD_DIR)/ser2net

$(SER2NET_DIR)/.source:
	zcat $(SER2NET_SOURCE) | tar -xvf -
	touch $(SER2NET_DIR)/.source

source: $(SER2NET_DIR)/.source
                        
$(SER2NET_DIR)/.configured: $(SER2NET_DIR)/.source
	(cd $(SER2NET_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS) -Wall" \
	./configure --prefix=/usr --with-tcp-wrappers )
	touch $(SER2NET_DIR)/.configured
                                                                 
$(SER2NET_DIR)/.build: $(SER2NET_DIR)/.configured
	mkdir -p $(SER2NET_TARGET_DIR)
	mkdir -p $(SER2NET_TARGET_DIR)/etc/init.d	
	mkdir -p $(SER2NET_TARGET_DIR)/usr/sbin	
	make -C $(SER2NET_DIR) all
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(SER2NET_DIR)/ser2net
	cp -aL ser2net.init $(SER2NET_TARGET_DIR)/etc/init.d/ser2net
	cp -aL ser2net.conf $(SER2NET_TARGET_DIR)/etc
	cp -a $(SER2NET_DIR)/ser2net $(SER2NET_TARGET_DIR)/usr/sbin
	cp -a $(SER2NET_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SER2NET_DIR)/.build

build: $(SER2NET_DIR)/.build
                                                                                         
clean:
	make -C $(SER2NET_DIR) clean
	rm -rf $(SER2NET_TARGET_DIR)
	rm -rf $(SER2NET_DIR)/.build
	rm -rf $(SER2NET_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(SER2NET_DIR) 
	rm -rf $(SER2NET_DIR)/.source
