# makefile for wget
include $(MASTERMAKEFILE)

WGET_DIR:=wget-1.13.4
WGET_TARGET_DIR:=$(BT_BUILD_DIR)/wget
#CFLAGS="$(BT_COPT_FLAGS) -g -Wall -Wno-implicit -DINET6"
CFLAGS="$(BT_COPT_FLAGS) -g -Wall -Wno-implicit"

$(WGET_DIR)/.source:
	zcat $(WGET_SOURCE) | tar -xvf -
	touch $(WGET_DIR)/.source

source: $(WGET_DIR)/.source
                        
$(WGET_DIR)/.build: $(WGET_DIR)/.source
	mkdir -p $(WGET_TARGET_DIR)
	mkdir -p $(WGET_TARGET_DIR)/etc
	mkdir -p $(WGET_TARGET_DIR)/usr/bin

	#Build a version without SSL support
	(cd $(WGET_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	CFLAGS=$(CFLAGS) \
	./configure \
	     --prefix=/usr \
	     --sysconfdir=/etc \
	     --disable-nls \
	     --disable-debug \
	     --disable-iri \
	     --without-gpg-error \
	     --without-gcrpyt \
	     --without-ssl \
	)

	make CC=$(TARGET_CC) -C $(WGET_DIR)
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(WGET_DIR)/src/wget
	cp -a $(WGET_DIR)/src/wget $(WGET_TARGET_DIR)/usr/bin

	make -C $(WGET_DIR) distclean

# hack cause distclean removes files like src/css.c
	zcat $(WGET_SOURCE) | tar -xvf -


	#Build a version with SSL support
	(cd $(WGET_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	CFLAGS=$(CFLAGS) \
	./configure \
	     --prefix=/usr \
	     --sysconfdir=/etc \
	     --disable-nls \
	     --disable-debug \
	     --disable-iri \
	     --without-gpg-error \
	     --without-gcrpyt \
	     --with-ssl=openssl \
	     --with-libssl-prefix=$(BT_STAGING_DIR)/usr \
	)
	make CC=$(TARGET_CC) -C $(WGET_DIR) 
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(WGET_DIR)/src/wget
	cp -a $(WGET_DIR)/src/wget $(WGET_TARGET_DIR)/usr/bin/wget-ssl

	cp -aL wgetrc $(WGET_TARGET_DIR)/etc
	cp -a $(WGET_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(WGET_DIR)/.build

build: $(WGET_DIR)/.build
                                                                                         
clean:
	make -C $(WGET_DIR) clean
	rm -rf $(WGET_TARGET_DIR)
	rm -f $(WGET_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(WGET_DIR) 
	rm -f $(WGET_DIR)/.source
