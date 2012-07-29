#####################################################
#
# pwcrypt setup
#
#####################################################
include $(MASTERMAKEFILE)

#####################################################
# Build pwcrypt

PWCRYPT_DIR:=pwcrypt-1.2.2
PWCRYPT_TARGET_DIR:=$(BT_BUILD_DIR)/pwcrypt

source: $(PWCRYPT_DIR)/.source

$(PWCRYPT_DIR)/.source:
	zcat $(PWCRYPT_SOURCE) | tar -xvf -
	touch $(PWCRYPT_DIR)/.source

$(PWCRYPT_DIR)/.configured: $(PWCRYPT_DIR)/.source
	(cd $(PWCRYPT_DIR); CC=$(TARGET_CC) LD=$(TARGET_LD) \
		./configure --prefix=/usr \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME) )
	touch $(PWCRYPT_DIR)/.configured

$(PWCRYPT_DIR)/.build: $(PWCRYPT_DIR)/.configured
	mkdir -p $(PWCRYPT_TARGET_DIR)
	mkdir -p $(PWCRYPT_TARGET_DIR)/usr/bin
	make $(MAKEOPTS) -C $(PWCRYPT_DIR)
	cp -a $(PWCRYPT_DIR)/src/pwcrypt $(PWCRYPT_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(DT_STRIP_BINOPTS) $(PWCRYPT_TARGET_DIR)/usr/bin/*
	cp -a $(PWCRYPT_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(PWCRYPT_DIR)/.build

build: $(PWCRYPT_DIR)/.build

clean:
	make -C $(PWCRYPT_DIR) clean
	rm -rf $(PWCRYPT_TARGET_DIR)
	rm -rf $(PWCRYPT_DIR)/.build
	rm -rf $(PWCRYPT_DIR)/.configured

srcclean: clean
	rm -rf $(PWCRYPT_DIR)
	rm -rf $(PWCRYPT_DIR)/.source
