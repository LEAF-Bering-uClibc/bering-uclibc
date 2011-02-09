# makefile for openntp
include $(MASTERMAKEFILE)

OPENNTP_DIR:=openntpd-3.9p1
OPENNTP_TARGET_DIR:=$(BT_BUILD_DIR)/openntp

$(OPENNTP_DIR)/.source:
	zcat $(OPENNTP_SOURCE) | tar -xvf -
	cat $(OPENNTP_PATCH1) | patch -d $(OPENNTP_DIR) -p1
	cat $(OPENNTP_PATCH2) | patch -d $(OPENNTP_DIR) -p1

	touch $(OPENNTP_DIR)/.source

source: $(OPENNTP_DIR)/.source
                        
$(OPENNTP_DIR)/.configured: $(OPENNTP_DIR)/.source
	(cd $(OPENNTP_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" \
	./configure \
	--prefix=/usr \
	--host=$(GNU_ARCH)-linux \
	--build=$(GNU_ARCH)-linux \
	--without-ssl-dir \
	--with-builtin-arc4random \
	--sysconfdir=/etc/openntpd);
	touch $(OPENNTP_DIR)/.configured

	#--with-ssl-dir=PATH
	#--without-privsep-user \

                                                                 
$(OPENNTP_DIR)/.build: $(OPENNTP_DIR)/.configured
	mkdir -p $(OPENNTP_TARGET_DIR)
	mkdir -p $(OPENNTP_TARGET_DIR)/etc/default	
	mkdir -p $(OPENNTP_TARGET_DIR)/etc/init.d	
	mkdir -p $(OPENNTP_TARGET_DIR)/etc/openntpd
	mkdir -p $(OPENNTP_TARGET_DIR)/usr/sbin		
	make -C $(OPENNTP_DIR) all  
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENNTP_DIR)/ntpd	
	cp -a $(OPENNTP_DIR)/ntpd $(OPENNTP_TARGET_DIR)/usr/sbin/openntpd
	cp -a openntpd.default $(OPENNTP_TARGET_DIR)/etc/default/openntpd
	cp -a openntpd.init $(OPENNTP_TARGET_DIR)/etc/init.d/openntpd
	cp -a ntpd.conf $(OPENNTP_TARGET_DIR)/etc/openntpd/
	cp -a $(OPENNTP_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(OPENNTP_DIR)/.build

build: $(OPENNTP_DIR)/.build
                                                                                         
clean:
	make -C $(OPENNTP_DIR) clean
	rm -rf $(OPENNTP_TARGET_DIR)
	-rm $(OPENNTP_DIR)/.build
	-rm $(OPENNTP_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -rf $(OPENNTP_DIR) 
