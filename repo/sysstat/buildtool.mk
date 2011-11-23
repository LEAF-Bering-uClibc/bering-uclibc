#############################################################
#
# buildtool makefile for strace
#
#############################################################

include $(MASTERMAKEFILE)

DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(DIR),)
DIR:=$(shell cat DIRNAME)
endif

TARGET_DIR:=$(BT_BUILD_DIR)/sysstat

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
CONFOPTS:=--prefix=/usr --disable-nls --disable-documentation

$(DIR)/.source:
	bzcat $(SOURCE) | tar -xvf -
	echo $(DIR) > DIRNAME
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.configure: $(DIR)/.source
	( cd $(DIR); CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
	CFLAGS="$(BT_COPT_FLAGS)" LDFLAGS="$(BT_LDFLAGS)" \
	./configure $(CONFOPTS) );
	touch $(DIR)/.configure

$(DIR)/.build: $(DIR)/.configure
	mkdir -p $(TARGET_DIR)
	$(MAKE) -C $(DIR)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/bin/*
	cp -ra $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	$(MAKE) -C $(DIR) clean

srcclean:
	rm -rf $(DIR)
	-rm DIRNAME

