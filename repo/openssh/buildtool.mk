#############################################################
#
# openssh
#
# $Id: buildtool.mk,v 1.2 2010/12/03 20:30:17 kapeka Exp $
#############################################################

include $(MASTERMAKEFILE)

OPENSSH_DIR:=openssh-5.8p1
OPENSSH_TARGET_DIR:=$(BT_BUILD_DIR)/openssh
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment

$(OPENSSH_DIR)/.source:
	zcat $(OPENSSH_SOURCE) | tar -xvf -
	touch $(OPENSSH_DIR)/.source

$(OPENSSH_DIR)/.configured: $(OPENSSH_DIR)/.source
	(cd $(OPENSSH_DIR); rm -rf config.cache; autoconf; \
		CFLAGS="$(BT_COPT_FLAGS) -I$(BT_STAGING_DIR)/include -I$(BT_STAGING_DIR)/usr/include " \
		LDFLAGS="-s -L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib" \
		CC=$(TARGET_CC) \
		LD=$(TARGET_CC) \
		./configure \
		--target=$(GNU_ARCH)-linux \
		--prefix=/usr \
		--build=$(GNU_ARCH)-linux \
		--host=$(GNU_ARCH)-linux \
		--disable-lastlog \
		--disable-libutil \
		--disable-nls \
		--disable-pututxline \
		--disable-utmpx \
		--disable-wtmpx  \
		--disable-largefile \
		--sysconfdir=/etc/ssh \
		--without-pam \
		--with-ldflags=-s \
		--with-privsep-path=/var/run/sshd \
		--with-privsep-user=sshd  \
		--with-tcp-wrappers \
		--with-4in6=no \
		--without-sectok \
		--without-kerberos5 \
		--without-kerberos4 \
		--without-afs \
		--without-md5-passwords \
		--without-bsd-auth \
		--with-xauth=no );
	touch $(OPENSSH_DIR)/.configured

#		--without-opensc \
#		--includedir=$(BT_STAGING_DIR)/include:$(BT_STAGING_DIR)/usr/include \
#		--libdir=$(BT_STAGING_DIR)/lib:$(BT_STAGING_DIR)/usr/lib \
#LD_LIBRARY_PATH="$(BT_STAGING_DIR)/lib:$(BT_STAGING_DIR)/usr/lib:$(BT_STAGING_DIR)/usr/local/lib" \


$(OPENSSH_DIR)/.build: $(OPENSSH_DIR)/.configured
	make  CC=$(TARGET_CC) -C $(OPENSSH_DIR)
	-mkdir -p $(BT_STAGING_DIR)/usr/bin
	-mkdir -p $(BT_STAGING_DIR)/usr/sbin
	-mkdir -p $(BT_STAGING_DIR)/usr/libexec
	-mkdir -p $(BT_STAGING_DIR)/etc
	-mkdir -p $(BT_STAGING_DIR)/etc/init.d
	-mkdir -p $(OPENSSH_TARGET_DIR)/etc/init.d
	-mkdir -p $(OPENSSH_TARGET_DIR)/usr/bin
	-mkdir -p $(OPENSSH_TARGET_DIR)/usr/local
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/scp
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/stfp
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/sftp-server
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/ssh
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/ssh-agent
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/sshd
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/ssh-keygen
	-$(BT_STRIP) $(STRIP_OPTIONS) $(OPENSSH_DIR)/ssh-keyscan
	-make CC=$(TARGET_CC) DESTDIR=$(OPENSSH_TARGET_DIR) -C $(OPENSSH_DIR) install
	cp -aL sshd $(OPENSSH_TARGET_DIR)/etc/init.d/
	cp -aL sshd_config $(OPENSSH_TARGET_DIR)/etc/ssh/
	cp -aL ssh_config $(OPENSSH_TARGET_DIR)/etc/ssh/
	cp -aL makekey $(OPENSSH_TARGET_DIR)/usr/bin/
	cp -a -f $(OPENSSH_TARGET_DIR)/etc/* $(BT_STAGING_DIR)/etc/
	cp -f $(OPENSSH_TARGET_DIR)/usr/bin/* $(BT_STAGING_DIR)/usr/bin/
	cp -f $(OPENSSH_TARGET_DIR)/usr/sbin/* $(BT_STAGING_DIR)/usr/sbin/
	cp -f $(OPENSSH_TARGET_DIR)/usr/libexec/* $(BT_STAGING_DIR)/usr/libexec/
	touch $(OPENSSH_DIR)/.build

source: $(OPENSSH_DIR)/.source

build: $(OPENSSH_DIR)/.build

clean:
	rm -rf $(OPENSSH_DIR)/.build
	make -C $(OPENSSH_DIR) clean
	rm -rf $(OPENSSH_TARGET_DIR)

srcclean:
	rm -rf $(OPENSSH_DIR)


