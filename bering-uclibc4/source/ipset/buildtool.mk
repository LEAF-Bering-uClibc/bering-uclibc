#############################################################
#
# iptables
#
# $Id: buildtool.mk,v 1.1 2010/11/09 21:18:08 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
DIR:=ipset-4.4
TARGET_DIR:=$(BT_BUILD_DIR)/ipset

#IPhash settings
#max sets
IP_NF_SET_MAX=256
#max items count in set
IP_NF_SET_HASHSIZE=4096

$(DIR)/.source: 
	bzcat $(SOURCE) |  tar -xvf - 
	touch $(DIR)/.source

$(DIR)/.build: $(DIR)/Makefile
	mkdir -p $(TARGET_DIR)
	
	(export IP_NF_SET_MAX=$(IP_NF_SET_MAX); \
	export IP_NF_SET_HASHSIZE=$(IP_NF_SET_HASHSIZE); \
	cd $(DIR) && for i in $(KARCHS); do export LOCALVERSION="-$$i" ; \
	export KERNEL_DIR=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE) ; \
	export KBUILD_OUTPUT=$(BT_LINUX_DIR)-$$i ; \
	export INSTALL_MOD_PATH=$(BT_STAGING_DIR) ; \
	$(MAKE) clean && \
	$(MAKE) modules && \
	$(MAKE) GENKSYMS="$(BT_STAGING_DIR)/sbin/genksyms" DEPMOD="$(BT_DEPMOD)" modules_install || \
	exit 1 ; done; \
	$(MAKE) binaries; $(MAKE) PREFIX=$(TARGET_DIR) binaries_install)
	cp -a $(DIR)/kernel/include $(TARGET_DIR)/
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/sbin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/lib/ipset/*
	rm -rf $(TARGET_DIR)/lib/pkgconfig $(TARGET_DIR)/man
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

source: $(DIR)/.source 

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	-$(MAKE) -C $(DIR) clean
  
srcclean:
	rm -rf $(DIR)
