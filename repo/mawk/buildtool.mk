# makefile for mawk
include $(MASTERMAKEFILE)

MAWK_DIR:=mawk-1.3.4-20100625
MAWK_TARGET_DIR:=$(BT_BUILD_DIR)/mawk

$(MAWK_DIR)/.source:
	zcat $(MAWK_SOURCE) | tar -xvf -
	zcat $(MAWK_PATCH) | patch -d $(MAWK_DIR) -p1
	(cd $(MAWK_DIR); export DEB_BUILD_ARCH=i386; $(BT_DPATCH) apply-all;)	
	touch $(MAWK_DIR)/.source

source: $(MAWK_DIR)/.source
                        
$(MAWK_DIR)/.configured: $(MAWK_DIR)/.source
	(cd $(MAWK_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="-Os -g -Wall" ./configure )
	touch $(MAWK_DIR)/.configured
                                                                 
$(MAWK_DIR)/.build: $(MAWK_DIR)/.configured
	mkdir -p $(MAWK_TARGET_DIR)
	mkdir -p $(MAWK_TARGET_DIR)/usr/bin	
	perl -i -p -e "s,trap 0,trap - 0,g" ${MAWK_DIR}/test/mawktest
	perl -i -p -e "s,\strap\s*0,trap - 0,g" ${MAWK_DIR}/test/fpe_test
#	make CC=$(TARGET_CC) -C $(MAWK_DIR) DESTDIR=$(MAWK_TARGET_DIR)
	make CC=$(TARGET_CC) -C $(MAWK_DIR) 
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(MAWK_DIR)/mawk
	cp -a $(MAWK_DIR)/mawk $(MAWK_TARGET_DIR)/usr/bin	
	cp -a $(MAWK_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(MAWK_DIR)/.build

build: $(MAWK_DIR)/.build
                                                                                         
clean:
	rm -rf $(MAWK_TARGET_DIR)
	rm -f $(MAWK_DIR)/.build
	rm -f $(MAWK_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(MAWK_DIR) 
	rm -f $(MAWK_DIR)/.source
