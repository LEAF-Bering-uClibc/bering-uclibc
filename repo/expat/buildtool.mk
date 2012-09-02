#############################################################
#
# expat
#
#############################################################

include $(MASTERMAKEFILE)

EXPAT_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
EXPAT_TARGET_DIR:=$(BT_BUILD_DIR)/expat

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
CONFOPTS:=--prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME)

.source:
	zcat $(SOURCE) | tar -xvf -
	touch .source

.configure: .source
	( cd $(EXPAT_DIR); ./configure $(CONFOPTS) );
	touch .configure
	
source: .source

.build: .configure
	mkdir -p $(EXPAT_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) -C $(EXPAT_DIR)
	$(MAKE) DESTDIR=$(EXPAT_TARGET_DIR) -C $(EXPAT_DIR) install
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(EXPAT_TARGET_DIR)/usr/lib/*.so
	# Fix libdir path for libtool
	perl -i -p -e "s,^libdir=.*,libdir=$(BT_STAGING_DIR)/usr/lib," $(EXPAT_TARGET_DIR)/usr/lib/*.la
	cp -a $(EXPAT_TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib
	cp -a $(EXPAT_TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include
	touch .build

build: .build

clean:
	-rm .build
	-rm .configure
	-rm -rf $(EXPAT_TARGET_DIR)
	-$(MAKE) -C $(EXPAT_DIR) clean
	
srcclean:
	-rm -rf $(EXPAT_DIR)
	-rm .source
