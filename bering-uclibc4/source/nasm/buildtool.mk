#############################################################
#
# nasm
#
#############################################################

include $(MASTERMAKEFILE)
NASM_DIR:= nasm-2.08.02
NASM_TARGET_DIR:=$(BT_STAGING_DIR)/usr

$(NASM_DIR)/.source: 
	bzcat $(NASM_SOURCE) |  tar -xvf - 
#	zcat $(NASM_PATCH1) | patch -d $(NASM_DIR) -p1
	-mkdir $(NASM_TARGET_DIR)
	touch $(NASM_DIR)/.source

$(NASM_DIR)/.configured: $(NASM_DIR)/.source
	export CC=$(TARGET_CC)
	(cd $(NASM_DIR); \
		./configure --prefix=$(NASM_TARGET_DIR) );
	touch $(NASM_DIR)/.configured

$(NASM_DIR)/.build: $(NASM_DIR)/.configured
	-mkdir -p $(NASM_TARGET_DIR)/man/man1
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(NASM_DIR) 
	$(MAKE) -C $(NASM_DIR) install
	touch $(NASM_DIR)/.build

source: $(NASM_DIR)/.source 

build: $(NASM_DIR)/.build

clean:
	-rm -rf $(NASM_DIR)/.build
	-rm -rf $(NASM_TARGET_DIR)/bin/nasm
	-rm -rf $(NASM_TARGET_DIR)/bin/ndisasm
	-rm -rf $(NASM_TARGET_DIR)/man/man1/nasm.1
	-rm -rf $(NASM_TARGET_DIR)/man/man1/ndisasm.1
	$(MAKE) -C $(NASM_DIR) clean
  
srcclean:
	rm -rf $(NASM_DIR)
