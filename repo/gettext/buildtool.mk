#############################################################
#
# $Id:
#
#############################################################

include $(MASTERMAKEFILE)
DIR:=gettext-0.18.1.1
TARGET_DIR:=$(BT_BUILD_DIR)/gettext
export CC=$(TARGET_CC)
PERLVER=$(shell ls $(BT_STAGING_DIR)/usr/lib/perl5)
export PERLLIB=$(BT_STAGING_DIR)/usr/lib/perl5/$(PERLVER)

$(DIR)/.source:
	zcat $(SOURCE) |  tar -xvf -
	touch $(DIR)/.source


$(DIR)/.configured: $(DIR)/.source
	(cd $(DIR); \
		CFLAGS="$(BT_COPT_FLAGS)" ./configure \
		--build=i486-pc-linux-gnu --host=i486-pc-linux-gnu \
		--prefix=/usr);
#	./autogen.sh --quick --skip-gnulib && \
	touch $(DIR)/.configured

source: $(DIR)/.source

$(DIR)/.build: $(DIR)/.configured
	mkdir -p $(TARGET_DIR)
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/include
	$(MAKE) CFLAGS="$(BT_COPT_FLAGS)" -C $(DIR)/gettext-runtime/intl
	$(MAKE) CFLAGS="$(BT_COPT_FLAGS)" DESTDIR=$(TARGET_DIR) \
		-C $(DIR)/gettext-runtime/intl install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TARGET_DIR)/usr/lib/*
	cp -a $(TARGET_DIR)/usr/lib/* $(BT_STAGING_DIR)/usr/lib/
	cp -a $(TARGET_DIR)/usr/include/* $(BT_STAGING_DIR)/usr/include/
	touch $(DIR)/.build

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build
	rm -rf $(TARGET_DIR)
	rm -f $(BT_STAGING_DIR)/usr/lib/libintl.*
	rm -f $(BT_STAGING_DIR)/usr/include/libintl.h
	$(MAKE) -C $(DIR) clean

srcclean:
	rm -rf $(DIR)

