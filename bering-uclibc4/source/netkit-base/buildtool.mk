#############################################################
#
# netkit-base
#
# $Id: buildtool.mk,v 1.1.1.1 2010/04/26 09:03:10 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
NETKIT_BASE_DIR:=netkit-base
NETKIT_BASE_TARGET_DIR:=$(BT_BUILD_DIR)/netkit-base


$(NETKIT_BASE_DIR)/.source: 
	zcat $(NETKIT_BASE_SOURCE) |  tar -xvf - 
	cat $(NETKIT_BASE_PATCH) |  patch -p1 -d $(NETKIT_BASE_DIR)
	touch $(NETKIT_BASE_DIR)/.source

$(NETKIT_BASE_DIR)/.build: $(NETKIT_BASE_DIR)/.source
	mkdir -p $(NETKIT_BASE_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	(cd $(NETKIT_BASE_DIR) ; \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		CFLAGS="$(BT_COPT_FLAGS)" \
		./configure --prefix=/usr --enable-ipv6  )
	
	perl -i -p -e 's,-O2,,' $(NETKIT_BASE_DIR)/MCONFIG
	
	$(MAKE) -C $(NETKIT_BASE_DIR) SUB=inetd 
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(NETKIT_BASE_DIR)/inetd/inetd
	cp -a  $(NETKIT_BASE_DIR)/inetd/inetd  $(NETKIT_BASE_TARGET_DIR)
	cp -a  $(NETKIT_BASE_DIR)/inetd/inetd  $(BT_STAGING_DIR)/usr/sbin/
	touch $(NETKIT_BASE_DIR)/.build

source: $(NETKIT_BASE_DIR)/.source 

build: $(NETKIT_BASE_DIR)/.build

clean:
	-rm $(NETKIT_BASE_DIR)/.build
	-$(MAKE) -C $(NETKIT_BASE_DIR) clean
  
srcclean:
	rm -rf $(NETKIT_BASE_DIR)
