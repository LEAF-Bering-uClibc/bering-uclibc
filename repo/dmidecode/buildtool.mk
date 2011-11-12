#############################################################
#
# buildtool makefile for dmidecode
#
#############################################################

include $(MASTERMAKEFILE)

DMI_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(DMI_SOURCE) 2>/dev/null )
ifeq ($(DMI_DIR),)
DMI_DIR:=$(shell cat DIRNAME)
endif
DMI_TARGET_DIR:=$(BT_BUILD_DIR)/dmidecode

$(DMI_DIR)/.source:
	zcat $(DMI_SOURCE) | tar -xvf -
	echo $(DMI_DIR) > DIRNAME
#	cat $(DMI_PATCH1) | patch -p1 -d $(DMI_DIR)
	touch $(DMI_DIR)/.source

source: $(DMI_DIR)/.source
                                                                 
$(DMI_DIR)/.build: $(DMI_DIR)/.source
	mkdir -p $(DMI_TARGET_DIR)
	make CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(DMI_DIR) DESTDIR=$(DMI_TARGET_DIR) prefix=/usr install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DMI_TARGET_DIR)/usr/sbin/*
	cp -a $(DMI_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DMI_DIR)/.build

build: $(DMI_DIR)/.build
                                                                                         
clean:
	rm -rf $(DMI_TARGET_DIR)
	rm -f $(DMI_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(DMI_DIR) 
	-rm DIRNAME

