# makefile for tftp
include $(MASTERMAKEFILE)

DIR:=mbus-0.1.2
TARGET_DIR:=$(BT_BUILD_DIR)/mbusd
PERLVER:=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)
export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER)

#LIBS = -liberty
#TFTPD_LIBS = -lwrap -liberty

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	cat $(PATCH1) | patch -p1 -d $(DIR)
#	cat $(PATCH2) | patch -p1 -d $(DIR)
#	cat $(PATCH3) | patch -p0 -d $(DIR)/src
	touch $(DIR)/.source

source: $(DIR)/.source
                        
$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS) -DTRXCTL" \
	./autogen.sh --prefix=/usr)
#	; \
#	./configure --prefix=/usr)
	touch $(DIR)/.configured

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/bin
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/etc/default
	AM_CFLAGS="$(BT_COPT_FLAGS) -DTRXCTL" make -C $(DIR)
	cp -a $(DIR)/src/mbusd $(TARGET_DIR)/usr/bin
	cp -aL mbusd.init $(TARGET_DIR)/etc/init.d/mbusd
	cp -aL mbusd.default $(TARGET_DIR)/etc/default/mbusd
	-$(BT_STRIP) -s $(BT_STRIP_BINOPTS) $(DIR)/usr/bin/*
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	make -C $(DIR) clean
	rm -rf $(TARGET_DIR)
	rm -rf $(DIR)/.build
	rm -rf $(DIR)/.configured

srcclean: clean
	rm -rf $(DIR) 
	rm -rf $(DIR)/.source
