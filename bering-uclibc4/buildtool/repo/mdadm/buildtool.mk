# makefile for mdadm
include $(MASTERMAKEFILE)

MDADM_DIR:=mdadm-2.5.6
MDADM_TARGET_DIR:=$(BT_BUILD_DIR)/mdadm

$(MDADM_DIR)/.source:
	zcat $(MDADM_SOURCE) | tar -xvf -
	cat $(MDADM_PATCH1) | patch -d $(MDADM_DIR) -p1
	touch $(MDADM_DIR)/.source

source: $(MDADM_DIR)/.source

                        
$(MDADM_DIR)/.build:
	mkdir -p $(MDADM_TARGET_DIR)
	mkdir -p $(MDADM_TARGET_DIR)/sbin
	mkdir -p $(MDADM_TARGET_DIR)/etc/init.d
	$(MAKE) CC=$(TARGET_CC) CXFLAGS="$(BT_COPT_FLAGS) -DUCLIBC -fno-strict-aliasing" -C $(MDADM_DIR)
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MDADM_DIR)/mdadm
	cp -a $(MDADM_DIR)/mdadm $(MDADM_TARGET_DIR)/sbin
	cp -aL mdadm.init $(MDADM_TARGET_DIR)/etc/init.d/mdadm
	cp -aL mdadm-raid.init $(MDADM_TARGET_DIR)/etc/init.d/mdadm-raid
	cp -aL mdadm.conf $(MDADM_TARGET_DIR)/etc
	cp -aL md-syslog-events $(MDADM_TARGET_DIR)/sbin
	cp -a $(MDADM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(MDADM_DIR)/.build

build: $(MDADM_DIR)/.build
                                                                                         
clean:
	make -C $(MDADM_DIR) clean
	rm -rf $(MDADM_TARGET_DIR)
	rm -f $(MDADM_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(MDADM_DIR) 
	rm -f $(MDADM_DIR)/.source