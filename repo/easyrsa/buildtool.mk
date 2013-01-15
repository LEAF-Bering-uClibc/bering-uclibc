#
#
#
include $(MASTERMAKEFILE)

EASYRSA_DIR:=easy-rsa-2.2.0_master
EASYRSA_TARGET_DIR:=$(BT_BUILD_DIR)/easyrsa

$(EASYRSA_DIR)/.source:
	zcat $(EASYRSA_SOURCE) | tar -xvf -
	perl -i -p -e 's,#!/bin/bash,#!/bin/sh,' $(EASYRSA_DIR)/easy-rsa/2.0/clean-all
	perl -i -p -e 's,#!/bin/bash,#!/bin/sh,' $(EASYRSA_DIR)/easy-rsa/2.0/list-crl
	perl -i -p -e 's,#!/bin/bash,#!/bin/sh,' $(EASYRSA_DIR)/easy-rsa/2.0/revoke-full
	perl -i -p -e 's,#!/bin/bash,#!/bin/sh,' $(EASYRSA_DIR)/easy-rsa/2.0/vars
	perl -i -p -e 's,#!/bin/bash,#!/bin/sh,' $(EASYRSA_DIR)/easy-rsa/2.0/build-dh
	perl -i -p -e 's,^export D=.*$$,export D=/etc/openvpn,' $(EASYRSA_DIR)/easy-rsa/2.0/vars
	perl -i -p -e 's,^export KEY_CONFIG.*$$,export KEY_CONFIG=/etc/easyrsa/openssl.cnf,' $(EASYRSA_DIR)/easy-rsa/2.0/vars
	touch $(EASYRSA_DIR)/.source


$(EASYRSA_DIR)/.build: $(EASYRSA_DIR)/.source
	mkdir -p $(EASYRSA_TARGET_DIR)/etc/easyrsa
	mkdir -p $(EASYRSA_TARGET_DIR)/usr/sbin

	(cd $(EASYRSA_DIR); \
		rm -rf config.cache; \
		./configure)

		make $(MAKEOPTS) -C $(EASYRSA_DIR)
		make DESTDIR=$(EASYRSA_TARGET_DIR) -C $(EASYRSA_DIR) install

		cp $(EASYRSA_DIR)/easy-rsa/2.0/clean-all $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/openssl-1.0.0.cnf $(EASYRSA_TARGET_DIR)/etc/easyrsa/openssl.cnf
		cp $(EASYRSA_DIR)/easy-rsa/2.0/list-crl $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/inherit-inter $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/pkitool $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/sign-req $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/build-dh $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/build-ca $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/revoke-full $(EASYRSA_TARGET_DIR)/usr/sbin/
		cp $(EASYRSA_DIR)/easy-rsa/2.0/vars $(EASYRSA_TARGET_DIR)/etc/easyrsa/

		cp -a $(EASYRSA_TARGET_DIR)/* $(BT_STAGING_DIR)
		touch $(EASYRSA_DIR)/.build

source: $(EASYRSA_DIR)/.source

build: $(EASYRSA_DIR)/.build

clean:
	-rm $(EASYRSA_DIR)/.build
	make -C $(EASYRSA_DIR) clean
	rm -rf $(EASYRSA_TARGET_DIR)

srcclean:
	rm -rf $(EASYRSA_DIR)
