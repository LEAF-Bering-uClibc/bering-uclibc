# makefile for beep
include $(MASTERMAKEFILE)

BEEP_DIR:=beep-1.3
BEEP_TARGET_DIR:=$(BT_BUILD_DIR)/beep

$(BEEP_DIR)/.source:
	zcat $(BEEP_SOURCE) | tar -xvf -
	touch $(BEEP_DIR)/.source

source: $(BEEP_DIR)/.source
                                                                 
$(BEEP_DIR)/.build: $(BEEP_DIR)/.source
	mkdir -p $(BEEP_TARGET_DIR)
	mkdir -p $(BEEP_TARGET_DIR)/bin	
	make CC=$(TARGET_CC) FLAGS="$(BT_COPT_FLAGS) -Wall" -C $(BEEP_DIR) DESTDIR=$(BEEP_TARGET_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(BEEP_DIR)/beep
	cp -a $(BEEP_DIR)/beep $(BEEP_TARGET_DIR)/bin	
	cp -a $(BEEP_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(BEEP_DIR)/.build

build: $(BEEP_DIR)/.build
                                                                                         
clean:
	rm -rf $(BEEP_TARGET_DIR)
	rm -f $(BEEP_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(BEEP_DIR) 
	rm -f $(BEEP_DIR)/.source
