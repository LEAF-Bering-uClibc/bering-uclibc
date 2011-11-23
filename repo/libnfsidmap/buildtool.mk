#############################################################
#
# buildtool makefile for libnfsidmap
#
#############################################################

include $(MASTERMAKEFILE)

LIBNFSIDMAP_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(LIBNFSIDMAP_SOURCE) 2>/dev/null )
ifeq ($(LIBNFSIDMAP_DIR),)
LIBNFSIDMAP_DIR:=$(shell cat DIRNAME)
endif
LIBNFSIDMAP_TARGET_DIR:=$(BT_BUILD_DIR)/libnfsidmap

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
CONFOPTS:=--prefix=/usr

$(LIBNFSIDMAP_DIR)/.source:
	zcat $(LIBNFSIDMAP_SOURCE) | tar -xvf -
	echo $(LIBNFSIDMAP_DIR) > DIRNAME
	touch $(LIBNFSIDMAP_DIR)/.source

source: $(LIBNFSIDMAP_DIR)/.source

$(LIBNFSIDMAP_DIR)/.configure: $(LIBNFSIDMAP_DIR)/.source
	( cd $(LIBNFSIDMAP_DIR) ; ./configure $(CONFOPTS) )
	touch $(LIBNFSIDMAP_DIR)/.configure

build: $(LIBNFSIDMAP_DIR)/.configure
	mkdir -p $(LIBNFSIDMAP_TARGET_DIR)
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(LIBNFSIDMAP_DIR)
	$(MAKE) -C $(LIBNFSIDMAP_DIR) DESTDIR=$(LIBNFSIDMAP_TARGET_DIR) install
#
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNFSIDMAP_TARGET_DIR)/usr/lib/libnfsidmap*.so
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(LIBNFSIDMAP_TARGET_DIR)/usr/lib/libnfsidmap/*.so
	perl -i -p -e "s,(/usr/lib),$(BT_STAGING_DIR)\1," $(LIBNFSIDMAP_TARGET_DIR)/usr/lib/*.la
	perl -i -p -e "s,(/usr/lib),$(BT_STAGING_DIR)\1," $(LIBNFSIDMAP_TARGET_DIR)/usr/lib/libnfsidmap/*.la
	cp -ap $(LIBNFSIDMAP_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
	cp -ap $(LIBNFSIDMAP_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include

clean:
	rm -rf $(LIBNFSIDMAP_TARGET_DIR)
	$(MAKE) -C $(LIBNFSIDMAP_DIR) clean
	rm -f $(LIBNFSIDMAP_DIR)/.configure

srcclean: clean
	rm -rf $(LIBNFSIDMAP_DIR)
	-rm DIRNAME

