#############################################################
#
# LUA
#
#############################################################

LUA_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LUA_SOURCE) 2>/dev/null )
LUA_TARGET_DIR:=$(BT_BUILD_DIR)/lua

$(LUA_DIR)/.source:
	zcat $(LUA_SOURCE) |  tar -xvf -
	touch $(LUA_DIR)/.source

$(LUA_DIR)/.build: $(LUA_DIR)/.source
	mkdir -p $(LUA_TARGET_DIR)
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) AR="$(TARGET_AR) rcu " \
	 RANLIB=$(TARGET_RANLIB) MYLIBS="-lncurses" CFLAGS="$(CFLAGS) -fPIC" \
	 MYLDFLAGS="$(LDFLAGS)" $(MAKEOPTS) -C $(LUA_DIR) linux
	$(MAKE) INSTALL_TOP=$(LUA_TARGET_DIR) $(MAKEOPTS) -C $(LUA_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LUA_TARGET_DIR)/bin/*
	-rm -rf $(LUA_TARGET_DIR)/share
	cp -a $(LUA_TARGET_DIR)/* $(BT_STAGING_DIR)/usr/
	touch $(LUA_DIR)/.build

source: $(LUA_DIR)/.source

build: $(LUA_DIR)/.build

clean:
	-rm $(LUA_DIR)/.build
	$(MAKE) -C $(LUA_DIR) clean

srcclean:
	rm -rf $(LUA_DIR)

