#############################################################
#
# openssh
#
# $Id: buildtool.mk,v 1.2 2010/12/03 20:30:17 kapeka Exp $
#############################################################

include $(MASTERMAKEFILE)

OPENSSH_DIR:=openssh-5.8p1
OPENSSH_TARGET_DIR:=$(BT_BUILD_DIR)/openssh

$(OPENSSH_DIR)/.source:
	zcat $(OPENSSH_SOURCE) | tar -xvf -
	touch $(OPENSSH_DIR)/.source

$(OPENSSH_DIR)/.configured: $(OPENSSH_DIR)/.source
	(cd $(OPENSSH_DIR); autoreconf -i -f && \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/usr \
		--disable-lastlog \
		--disable-libutil \
		--disable-pututxline \
		--disable-utmpx \
		--disable-wtmpx  \
		--disable-largefile \
		--sysconfdir=/etc/ssh \
		--without-rpath \
		--without-pam \
		--with-privsep-path=/var/run/sshd \
		--with-privsep-user=sshd  \
		--with-tcp-wrappers \
		--with-4in6=no \
		--without-kerberos5 \
		--without-md5-passwords \
		--without-bsd-auth \
		--with-xauth=no );
	touch $(OPENSSH_DIR)/.configured

#		--without-opensc \
#		--includedir=$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/usr/include \
#		--libdir=$(BT_STAGING_DIR)/lib:$(BT_STAGING_DIR)/usr/lib \
#LD_LIBRARY_PATH="$(BT_STAGING_DIR)/lib:$(BT_STAGING_DIR)/usr/lib:$(BT_STAGING_DIR)/usr/local/lib" \


$(OPENSSH_DIR)/.build: $(OPENSSH_DIR)/.configured
	mkdir -p $(OPENSSH_TARGET_DIR)/etc/init.d
	mkdir -p $(OPENSSH_TARGET_DIR)/etc/ssh
	make $(MAKEOPTS) -C $(OPENSSH_DIR)
	-make DESTDIR=$(OPENSSH_TARGET_DIR) -C $(OPENSSH_DIR) install
	cp -aL sshd $(OPENSSH_TARGET_DIR)/etc/init.d/
	cp -aL sshd_config $(OPENSSH_TARGET_DIR)/etc/ssh/
	cp -aL ssh_config $(OPENSSH_TARGET_DIR)/etc/ssh/
	cp -aL makekey $(OPENSSH_TARGET_DIR)/usr/bin/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSSH_TARGET_DIR)/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSSH_TARGET_DIR)/usr/sbin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(OPENSSH_TARGET_DIR)/usr/libexec/*
	rm -rf $(OPENSSH_TARGET_DIR)/usr/share
	cp -a -f $(OPENSSH_TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(OPENSSH_DIR)/.build

source: $(OPENSSH_DIR)/.source

build: $(OPENSSH_DIR)/.build

clean:
	rm -rf $(OPENSSH_DIR)/.build
	make -C $(OPENSSH_DIR) clean
	rm -rf $(OPENSSH_TARGET_DIR)

srcclean:
	rm -rf $(OPENSSH_DIR)


