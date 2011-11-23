
# makefile for gnupg
include $(MASTERMAKEFILE)

GNUPG_DIR:=gnupg-1.4.11
GNUPG_TARGET_DIR:=$(BT_BUILD_DIR)/gnupg

.source:
	zcat $(GNUPG_SOURCE) | tar -xvf -
	touch .source

source: .source

$(GNUPG_DIR)/.configured: .source
	(cd $(GNUPG_DIR) ; \
	CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" ./configure --without-readline \
	--disable-gnupg-iconv --disable-asm --disable-card-support --disable-nls )
	touch $(GNUPG_DIR)/.configured

$(GNUPG_DIR)/.build: $(GNUPG_DIR)/.configured
	mkdir -p $(GNUPG_TARGET_DIR)
	(cd $(GNUPG_DIR) ; make )
	cp -a $(GNUPG_DIR)/g10/gpg $(GNUPG_TARGET_DIR)
	cp -a $(GNUPG_DIR)/g10/gpgv $(GNUPG_TARGET_DIR)

	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(GNUPG_TARGET_DIR)/gpg
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(GNUPG_TARGET_DIR)/gpgv
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
