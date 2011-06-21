# makefile for dhcpd
include $(MASTERMAKEFILE)

DIR:=dhcdrop-0.5
TARGET_DIR:=$(BT_BUILD_DIR)/dhcdrop
                        
$(DIR)/.source:
	bzcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source
	
$(DIR)/Makefile:
	(cd $(DIR) ; CC=$(TARGET_CC) CFLAGS=$(CFLAGS) LD=$(TARGET_LD) \
		./configure  --prefix=/usr )

source: $(DIR)/.source
                                                                 
$(DIR)/.build: $(DIR)/Makefile
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/sbin
	make -C $(DIR) CC=$(TARGET_CC)
	$(MAKE) CC=$(TARGET_CC) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/dhcdrop
	rm -rf $(TARGET_DIR)/usr/share
	cp -aL $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build
                                                                                         
clean:
	make -C $(DIR) distclean
	rm -rf $(TARGET_DIR)
	rm $(DIR)/Makefile
	rm $(DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(DIR) 
