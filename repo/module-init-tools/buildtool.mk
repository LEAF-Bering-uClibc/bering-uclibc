#############################################################
# modutils
#############################################################

include $(MASTERMAKEFILE)

DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(DIR),)
DIR:=$(shell cat DIRNAME)
endif
TARGET_DIR:=$(BT_BUILD_DIR)/module-init-tools


$(DIR)/.source:
	bzcat $(SOURCE) | tar -xvf -
	echo $(DIR) > DIRNAME
	touch $(DIR)/.source

source:	$(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(BT_BUILD_DIR)/module-init-tools
	(cd $(DIR); \
		rm -rf config.cache; \
		CFLAGS="$(BT_COPT_FLAGS)" \
		CC=$(TARGET_CC) \
		LD=$(TARGET_LD) \
		./configure --prefix=/);
	cat defs.patch|patch -p1 -d $(DIR)
	make DOCBOOKTOMAN="true" CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) HOSTCC=$(TARGET_CC) HOSTCFLAGS="$(BT_COPT_FLAGS)" LD=$(TARGET_LD) -C $(DIR)
	make DOCBOOKTOMAN="true" CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) HOSTCC=$(TARGET_CC) HOSTCFLAGS="$(BT_COPT_FLAGS)" LD=$(TARGET_LD) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/sbin/*
	-rm -rf $(TARGET_DIR)/share
	cp -R $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build:	$(DIR)/.build

clean:
	make CFLAGS="$(BT_COPT_FLAGS)" CC=$(TARGET_CC) LD=$(TARGET_LD) DESTDIR=$(BT_STAGING_DIR) -C $(DIR) clean
	rm -f $(DIR)/.build
	rm -rf $(BT_BUILD_DIR)/modutils

srcclean:
	rm -rf $(DIR)
	-rm DIRNAME

