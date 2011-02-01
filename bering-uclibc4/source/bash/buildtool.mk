# makefile for bash
include $(MASTERMAKEFILE)

BASH_DIR:=bash-3.2.48
BASH_TARGET_DIR:=$(BT_BUILD_DIR)/bash

$(BASH_DIR)/.source:
	zcat $(BASH_SOURCE) | tar -xvf -
	touch $(BASH_DIR)/.source

source: $(BASH_DIR)/.source
                        
$(BASH_DIR)/.configured: $(BASH_DIR)/.source
	(cd $(BASH_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="-Os" ./configure --host=i386-pc-linux-gnu \
			--with-curses --disable-net-redirections --prefix=/ \
			--infodir=/usr/share/info --mandir=/usr/share/man )
	touch $(BASH_DIR)/.configured
                                                                 
$(BASH_DIR)/.build: $(BASH_DIR)/.configured
	mkdir -p $(BASH_TARGET_DIR)
	mkdir -p $(BASH_TARGET_DIR)/bin
	make -C $(BASH_DIR) all  
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(BASH_DIR)/bash	
	cp -a $(BASH_DIR)/bash $(BASH_TARGET_DIR)/bin
	cp -a $(BASH_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(BASH_DIR)/.build

build: $(BASH_DIR)/.build
                                                                                         
clean:
	make -C $(BASH_DIR) clean
	rm -rf $(BASH_TARGET_DIR)
                                                                                                                 
srcclean: clean
	rm -rf $(BASH_DIR) 

