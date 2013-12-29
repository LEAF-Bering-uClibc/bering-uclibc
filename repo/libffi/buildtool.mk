############################################
# makefile for libffi
###########################################

LIBFFI_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(LIBFFI_SOURCE) 2>/dev/null)
LIBFFI_TARGET_DIR:=$(BT_BUILD_DIR)/libffi

$(LIBFFI_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(LIBFFI_SOURCE)
	touch $(LIBFFI_DIR)/.source

source: $(LIBFFI_DIR)/.source

$(LIBFFI_DIR)/.configured: $(LIBFFI_DIR)/.source
	(cd $(LIBFFI_DIR) ; CC=$(TARGET_CC) LD=$(TARGET_LD) \
	./configure \
	--prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) )
	touch $(LIBFFI_DIR)/.configured

$(LIBFFI_DIR)/.build: $(LIBFFI_DIR)/.configured
	mkdir -p $(LIBFFI_TARGET_DIR)
	mkdir -p $(LIBFFI_TARGET_DIR)/usr/lib
	mkdir -p $(LIBFFI_TARGET_DIR)/usr/include

	make $(MAKEOPTS) -C $(LIBFFI_DIR) DESTDIR=$(LIBFFI_TARGET_DIR) \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(CFLAGS)"

	cp -a $(LIBFFI_DIR)/$(GNU_TARGET_NAME)/.libs/libffi.* $(LIBFFI_TARGET_DIR)/usr/lib
	cp -a $(LIBFFI_DIR)/$(GNU_TARGET_NAME)/include/*.h $(LIBFFI_TARGET_DIR)/usr/include
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LIBFFI_TARGET_DIR)/usr/lib/*
	cp -a $(LIBFFI_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(LIBFFI_DIR)/.build

build: $(LIBFFI_DIR)/.build

clean:
	make -C $(LIBFFI_DIR) clean
	rm -rf $(LIBFFI_TARGET_DIR)
	rm -rf $(LIBFFI_DIR)/.build
	rm -rf $(LIBFFI_DIR)/.configured

srcclean: clean
	rm -rf $(LIBFFI_DIR)
