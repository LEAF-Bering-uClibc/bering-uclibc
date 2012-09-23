
# makefile for gnupg

GNUPG_DIR:=gnupg-1.4.11
GNUPG_TARGET_DIR:=$(BT_BUILD_DIR)/gnupg

.source:
	zcat $(GNUPG_SOURCE) | tar -xvf -
	touch .source

source: .source

$(GNUPG_DIR)/.configured: .source
	(cd $(GNUPG_DIR) ; ./configure --without-readline \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--disable-gnupg-iconv --disable-asm --disable-card-support --disable-nls )
	perl -i -p -e 's,checks\s*=\s*checks,,' $(GNUPG_DIR)/Makefile
	touch $(GNUPG_DIR)/.configured

$(GNUPG_DIR)/.build: $(GNUPG_DIR)/.configured
	mkdir -p $(GNUPG_TARGET_DIR)
	make $(MAKEOPTS) -C $(GNUPG_DIR)
	cp -a $(GNUPG_DIR)/g10/gpg $(GNUPG_TARGET_DIR)
	cp -a $(GNUPG_DIR)/g10/gpgv $(GNUPG_TARGET_DIR)

	-$(BT_STRIP) $(BTSTRIP_BINOPTS) $(GNUPG_TARGET_DIR)/*
	cp -a $(GNUPG_TARGET_DIR)/gpg $(BT_STAGING_DIR)/usr/bin
	cp -a $(GNUPG_TARGET_DIR)/gpgv $(BT_STAGING_DIR)/usr/bin

	touch $(GNUPG_DIR)/.build

build: $(GNUPG_DIR)/.build

clean:
	make -C $(GNUPG_DIR) clean
	rm -rf $(GNUPG_TARGET_DIR)
	rm -f $(GNUPG_DIR)/.build
	rm -f $(GNUPG_DIR)/.configured

srcclean: clean
	rm -rf $(GNUPG_DIR)
	rm .source
