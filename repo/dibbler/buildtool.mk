#############################################################
#
# buildtool makefile for dibbler
#
#############################################################


DIBBLER_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(DIBBLER_SOURCE) 2>/dev/null )
DIBBLER_TARGET_DIR:=$(BT_BUILD_DIR)/dibbler

$(DIBBLER_DIR)/.source:
	zcat $(DIBBLER_SOURCE) | tar -xvf -
	# Remove debuging parameters
	( cd $(DIBBLER_DIR) ; perl -i -p -e 's,-pedantic,,'	Makefile.inc )
	( cd $(DIBBLER_DIR) ; perl -i -p -e 's,-g,,'		Makefile.inc )
	( cd $(DIBBLER_DIR) ; perl -i -p -e 's,-lefence,,'	Makefile.inc )
	# Move installed files out from under /usr/local
	( cd $(DIBBLER_DIR) ; perl -i -p -e 's,local/,,'	Makefile.inc )
	touch $(DIBBLER_DIR)/.source

source: $(DIBBLER_DIR)/.source

$(DIBBLER_DIR)/Makefile: $(DIBBLER_DIR)/.source
	(cd $(DIBBLER_DIR); ./configure \
	    --host=$(GNU_TARGET_NAME) \
	    --build=$(GNU_BUILD_NAME) \
	    --prefix=/usr )

$(DIBBLER_DIR)/.build: $(DIBBLER_DIR)/Makefile
	mkdir -p $(DIBBLER_TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/sbin/
	mkdir -p $(BT_STAGING_DIR)/etc/init.d/
	mkdir -p $(BT_STAGING_DIR)/etc/dibbler/
	make $(MAKEOPTS) -C $(DIBBLER_DIR) all
	make DESTDIR=$(DIBBLER_TARGET_DIR) -C $(DIBBLER_DIR) install
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(DIBBLER_TARGET_DIR)/usr/sbin/*
	cp -a $(DIBBLER_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin/
	cp -a $(DIBBLER_TARGET_DIR)/usr/share/doc/dibbler/examples/server.conf $(BT_STAGING_DIR)/etc/dibbler/
	cp dibbler-server.init $(BT_STAGING_DIR)/etc/init.d/dibbler-server
	cp dibbler-server.daily $(BT_STAGING_DIR)/etc/cron.daily/dibbler-server
	touch $(DIBBLER_DIR)/.build

build: $(DIBBLER_DIR)/.build

clean:
	make -C $(DIBBLER_DIR) clean
	rm -rf $(DIBBLER_TARGET_DIR)
	-rm $(DIBBLER_DIR)/.build

srcclean: clean
	rm -rf $(DIBBLER_DIR)
