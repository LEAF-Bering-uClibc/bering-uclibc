#############################################################
#
# buildtool makefile for libevent
#
#############################################################

include $(MASTERMAKEFILE)

LIBEVENT_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBEVENT_SOURCE) 2>/dev/null )
LIBEVENT_TARGET_DIR:=$(BT_BUILD_DIR)/libevent

$(LIBEVENT_DIR)/.source:
	zcat $(LIBEVENT_SOURCE) | tar -xvf -
	touch $(LIBEVENT_DIR)/.source

source: $(LIBEVENT_DIR)/.source

$(LIBEVENT_DIR)/.configured: $(LIBEVENT_DIR)/.source
	(cd $(LIBEVENT_DIR) ; ./configure \
	--prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME))
	touch $(LIBEVENT_DIR)/.configured

$(LIBEVENT_DIR)/.build: $(LIBEVENT_DIR)/.configured
	mkdir -p $(LIBEVENT_TARGET_DIR)
	make $(MAKEOPTS) -C $(LIBEVENT_DIR) all
	make DESTDIR=$(LIBEVENT_TARGET_DIR) -C $(LIBEVENT_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBEVENT_TARGET_DIR)/usr/lib/*
	perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(LIBEVENT_TARGET_DIR)/usr/lib/*.la
	rm -rf $(LIBEVENT_TARGET_DIR)/usr/share
	cp -a -f $(LIBEVENT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBEVENT_DIR)/.build

build: $(LIBEVENT_DIR)/.build

clean:
	make -C $(LIBEVENT_DIR) clean
	rm -rf $(LIBEVENT_TARGET_DIR)
	rm -rf $(LIBEVENT_DIR)/.build
	rm -rf $(LIBEVENT_DIR)/.configured

srcclean: clean
	rm -rf $(LIBEVENT_DIR)
	rm -rf $(LIBEVENT_DIR)/.source
