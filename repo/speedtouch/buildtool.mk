#############################################################
#
# speedtouch
#
#############################################################

include $(MASTERMAKEFILE)

SPEEDTOUCH_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SPEEDTOUCH_SOURCE) 2>/dev/null )
SPEEDTOUCH_TARGET_DIR:=$(BT_BUILD_DIR)/speedtouch

$(SPEEDTOUCH_DIR)/.source:
	zcat $(SPEEDTOUCH_SOURCE) | tar -xvf -
	# Fix syntax error for Bering-uClibc 4.x
	perl -i -p -e 's,extern int verbose;,,' $(SPEEDTOUCH_DIR)/src/modem.h
	touch $(SPEEDTOUCH_DIR)/.source

source: $(SPEEDTOUCH_DIR)/.source

$(SPEEDTOUCH_DIR)/.configured: $(SPEEDTOUCH_DIR)/.source
	(cd $(SPEEDTOUCH_DIR) ; libtoolize -i -f && autoreconf -i -f && \
	./configure --prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--includedir=$(BT_STAGING_DIR)/usr/include \
	--oldincludedir=$(BT_STAGING_DIR)/usr/include )
	touch $(SPEEDTOUCH_DIR)/.configured

$(SPEEDTOUCH_DIR)/.build: $(SPEEDTOUCH_DIR)/.configured
	mkdir -p $(SPEEDTOUCH_TARGET_DIR)
	mkdir -p $(SPEEDTOUCH_TARGET_DIR)/usr/sbin
	make $(MAKEOPTS) -C $(SPEEDTOUCH_DIR) all
	cp -a $(SPEEDTOUCH_DIR)/src/modem_run $(SPEEDTOUCH_TARGET_DIR)/usr/sbin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SPEEDTOUCH_TARGET_DIR)/usr/sbin/*
	cp -a $(SPEEDTOUCH_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SPEEDTOUCH_DIR)/.build

build: $(SPEEDTOUCH_DIR)/.build

clean:
	make -C $(SPEEDTOUCH_DIR) clean
	rm -rf $(SPEEDTOUCH_TARGET_DIR)
	rm -rf $(SPEEDTOUCH_DIR)/.build
	rm -rf $(SPEEDTOUCH_DIR)/.configured

srcclean: clean
	rm -rf $(SPEEDTOUCH_DIR)
