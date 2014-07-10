#########################################################
# makefile for nspr
#########################################################

DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
TARGET_DIR:=$(BT_BUILD_DIR)/nspr

$(DIR)/.source:
	zcat $(SOURCE) | tar -xvf -
	touch $@

source: $(DIR)/.source

$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR)/nspr ; ./configure \
	    --host=$(GNU_TARGET_NAME) \
	    --build=$(GNU_BUILD_NAME) \
	    --target=$(GNU_TARGET_NAME) \
	    --prefix=/usr \
	    --with-pthreads \
	    )
	touch $@

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	make $(MAKEOPTS) -C $(DIR)/nspr all
	make DESTDIR=$(TARGET_DIR) -C $(DIR)/nspr install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	cp -a -f $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $@

build: $(DIR)/.build

clean:
	make -C $(DIR) clean
	rm -rf $(TARGET_DIR)
	rm -rf $(DIR)/.build
	rm -rf $(DIR)/.configured

srcclean: clean
	rm -rf $(DIR)
