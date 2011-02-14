#############################################################
#
# ipvsadm
#
#############################################################

include $(MASTERMAKEFILE)

IPVSADM_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(IPVSADM_SOURCE) 2>/dev/null )
ifeq ($(IPVSADM_DIR),)
IPVSADM_DIR:=$(shell cat DIRNAME)
endif
IPVSADM_TARGET_DIR:=$(BT_BUILD_DIR)/ipvsadm

CFLAGS = $(BT_COPT_FLAGS) -Wall -Wunused -Wstrict-prototypes -g
KERNELSOURCE = $(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)

$(IPVSADM_DIR)/.source:
	tar xvzf $(IPVSADM_SOURCE)
	echo $(IPVSADM_DIR) > DIRNAME
	touch $(IPVSADM_DIR)/.source

source: $(IPVSADM_DIR)/.source
                        
$(IPVSADM_DIR)/.build: $(IPVSADM_DIR)/.source
	mkdir -p $(IPVSADM_TARGET_DIR)
	mkdir -p $(IPVSADM_TARGET_DIR)/etc/
	mkdir -p $(IPVSADM_TARGET_DIR)/etc/init.d
	mkdir -p $(IPVSADM_TARGET_DIR)/etc/default
	mkdir -p $(IPVSADM_TARGET_DIR)/sbin
	make -C $(IPVSADM_DIR) LIB_SEARCH="$(BT_STAGING_DIR)/usr/lib $(BT_STAGING_DIR)/lib" CFLAGS="$(CFLAGS)" KERNELSOURCE=$(KERNELSOURCE) all
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(IPVSADM_DIR)/ipvsadm
	cp -a $(IPVSADM_DIR)/ipvsadm $(IPVSADM_TARGET_DIR)/sbin
	cp -aL ipvsadm.default $(IPVSADM_TARGET_DIR)/etc/default/ipvsadm
	cp -aL ipvsadm.rules $(IPVSADM_TARGET_DIR)/etc
	cp -aL ipvsadm.init $(IPVSADM_TARGET_DIR)/etc/init.d/ipvsadm
	cp -a $(IPVSADM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(IPVSADM_DIR)/.build

build: $(IPVSADM_DIR)/.build
                                                                                         
clean:
	make -C $(IPVSADM_DIR) clean
	rm -rf $(IPVSADM_DIR)/.build
	rm -rf $(IPVSADM_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(IPVSADM_DIR)

