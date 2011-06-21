#############################################################
#
# dosfstools
#
#############################################################

include $(MASTERMAKEFILE)
DOSFSTOOLS_DIR:=dosfstools-3.0.9
DOSFSTOOLS_TARGET_DIR:=$(BT_BUILD_DIR)/dosfstools
export CC=$(TARGET_CC)

$(DOSFSTOOLS_DIR)/.source: 
	zcat $(DOSFSTOOLS_SOURCE) |  tar -xvf - 
#	zcat $(DOSFSTOOLS_PATCH1) | patch -d $(DOSFSTOOLS_DIR) -p1
	perl -i -p -e 's,CC\s*=\s*gcc,#CC = gcc,' $(DOSFSTOOLS_DIR)/Makefile
	perl -i -p -e 's,PREFIX\s*=.*,PREFIX = $(DOSFSTOOLS_TARGET_DIR),' $(DOSFSTOOLS_DIR)/Makefile
	-mkdir $(DOSFSTOOLS_TARGET_DIR)

$(DOSFSTOOLS_DIR)/.build: $(DOSFSTOOLS_DIR)/.source
	export PREFIX=$(DOSFSTOOLS_TARGET_DIR)
	$(MAKE) OPTFLAGS="$(BT_COPT_FLAGS) -fomit-frame-pointer" CC=$(TARGET_CC) -C $(DOSFSTOOLS_DIR) 
	$(MAKE) CC=$(TARGET_CC) -C $(DOSFSTOOLS_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DOSFSTOOLS_TARGET_DIR)/sbin/mkdosfs
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DOSFSTOOLS_TARGET_DIR)/sbin/dosfsck
	mkdir -p $(BT_STAGING_DIR)/sbin
	-cp $(DOSFSTOOLS_TARGET_DIR)/sbin/mkdosfs $(BT_STAGING_DIR)/sbin/
	-cp $(DOSFSTOOLS_TARGET_DIR)/sbin/dosfsck $(BT_STAGING_DIR)/sbin/
	touch $(DOSFSTOOLS_DIR)/.build

source: $(DOSFSTOOLS_DIR)/.source 

build: $(DOSFSTOOLS_DIR)/.build

clean:
	rm -rf $(DOSFSTOOLS_TARGET_DIR)
	-rm $(DOSFSTOOLS_DIR)/.build
	$(MAKE) -C $(DOSFSTOOLS_DIR) clean
  
srcclean:
	rm -rf $(DOSFSTOOLS_DIR)
