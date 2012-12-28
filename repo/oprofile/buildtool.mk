######################################
#
# buildtool make file for oprofile
#
######################################

include $(MASTERMAKEFILE)

DIR:=oprofile-0.9.6
TARGET_DIR:=$(BT_BUILD_DIR)/oprofile
PERLVER:=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)
export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER)

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
#	zcat $(PATCH) | patch -d $(DIR) -p1
	touch $(DIR)/.source	

source: $(DIR)/.source


$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR) ; ./autogen.sh ; \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" \
	./configure --prefix=/usr \
	--with-kernel-support \
	--with-sysroot=$(BT_STAGING_DIR) \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_HOST_NAME) )
	touch $(DIR)/.configured


$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	make -C $(DIR)
	make -C $(DIR) DESTDIR=$(TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/lib/oprofile/*
	cp -a $(TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
	mkdir -p $(BT_STAGING_DIR)/usr/share/oprofile
	(cd $(TARGET_DIR)/usr/share/oprofile; \
		cp -a stl.pat i386 x86-64 $(BT_STAGING_DIR)/usr/share/oprofile)
	touch $(DIR)/.build


build: $(DIR)/.build


clean:
	make -C $(DIR) clean
	rm -rf $(TARGET_DIR)
	rm -rf $(BT_STAGING_DIR)/usr/sbin/tcpdump
	rm -f $(DIR)/.build
	rm -f $(DIR)/.configured


srcclean: clean
	rm -rf $(DIR)
	rm -f $(DIR)/.source

