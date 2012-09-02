#############################################################
#
# buildtool makefile for strace
#
#############################################################

include $(MASTERMAKEFILE)

DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/sysstat

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
CONFOPTS:=--prefix=/usr --disable-nls --disable-documentation --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME)
export CFLAGS += $(LDFLAGS)

$(DIR)/.source:
	bzcat $(SOURCE) | tar -xvf -
	touch $(DIR)/.source

source: $(DIR)/.source

$(DIR)/.configure: $(DIR)/.source
	( cd $(DIR); ./configure $(CONFOPTS) );
	touch $(DIR)/.configure

$(DIR)/.build: $(DIR)/.configure
	mkdir -p $(TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(DIR)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	-rm -rf $(TARGET_DIR)/usr/share/doc
	cp -ra $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	$(MAKE) -C $(DIR) clean

srcclean:
	rm -rf $(DIR)
