#############################################################
#
# buildtool makefile for radius
#
#############################################################

include $(MASTERMAKEFILE)

RADIUS_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(RADIUS_SOURCE) 2>/dev/null )
ifeq ($(RADIUS_DIR),)
RADIUS_DIR:=$(shell cat DIRNAME)
endif
RADIUS_TARGET_DIR:=$(BT_BUILD_DIR)/radius

# Option settings for 'configure':
#   Move default install from /usr/local/ to /usr/
#   But put config in /etc/ rather than /usr/etc/
#   And put logfiles in /var/log/ rather than /usr/var/log/
#   Explicitly enable the modules referenced in the Package
#   Disable a whole raft of modules which require extra libraries
CONFOPTS:=--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
	--with-rlm_acctlog --with-rlm_acct_unique --with-rlm_always \
	--with-rlm_attr_filter --with-rlm_attr_rewrite --with-rlm_chap \
	--with-rlm_checkval --with-rlm_copy_packet --with-rlm_detail \
	--with-rlm_digest --with-rlm_dynamic_clients --with-rlm_eap \
	--with-rlm_eap_gtc --with-rlm_eap_leap --with-rlm_eap_md5 \
	--with-rlm_eap_mschapv2 --with-lm_eap_peap --with-rlm_eap_sim \
	--with-rlm_eap_tls --with-rlm_eap_ttls --with-rlm_exec \
	--with-rlm_expiration --with-rlm_expr --with-rlm_fastusers \
	--with-rlm_files --with-rlm_ldap --with-rlm_linelog \
	--with-rlm_logintime --with-rlm_mschap --with-rlm_otp \
	--with-rlm_pap --with-rlm_passwd --with-rlm_policy \
	--with-rlm_preprocess --with-rlm_radutmp --with-rlm_realm \
	--with-rlm_sql --with-rlm_sqlcounter --with-rlm_sqlippool \
	--with-rlm_sql_log --with-rlm_sql_mysql --with-rlm_unix \
	--without-rlm_ippool --without-rlm_sql_unixodbc \
	--without-rlm_counter --without-rlm_dbm \
	--without-rlm_eap_tnc --without-rlm-krb5 --without-rlm-eap_ikev2 \
	--without-rlm-perl --without-rlm-pam \
	--without-rlm_sql_iodbc --without-rlm_python \
	--without-rlm_sql_oracle --without-rlm_sql_postgresql \
	--with-dhcp \
	--with-mysql-dir="$(BT_STAGING_DIR)"/usr 
#	--with-mysql-lib-dir="$(BT_STAGING_DIR)"/usr/lib

$(RADIUS_DIR)/.source:
	bzcat $(RADIUS_SOURCE) | tar -xvf -
	echo $(RADIUS_DIR) > DIRNAME
	touch $(RADIUS_DIR)/.source

source: $(RADIUS_DIR)/.source

$(RADIUS_DIR)/.configure: $(RADIUS_DIR)/.source
	( cd $(RADIUS_DIR) ; CFLAGS="$(BT_COPT_FLAGS)" \
	LDFLAGS='-L"$(BT_STAGING_DIR)"/lib -L"$(BT_STAGING_DIR)"/usr/lib' \
	./configure $(CONFOPTS) )
	# Fix for "unable to infer tagged configuration" errors
	( cd $(RADIUS_DIR) ; \
	  for file in src/lib/Makefile \
		      src/modules/rules.mak \
		      src/modules/rlm_eap/Makefile \
		      src/modules/rlm_eap/libeap/Makefile \
		      src/modules/rlm_mschap/Makefile \
		      src/modules/rlm_sql/drivers/rules.mak \
		      src/main/Makefile ; \
	  do \
	    sed -i -e "s/--mode=compile/--tag=CC --mode=compile/" $$file ; \
	    sed -i -e "s/--mode=link/--tag=CC --mode=link/" $$file ; \
	  done )
	# Fix for .lai install errors
	( cd $(RADIUS_DIR) ; sed -i -e "/instname/d" libtool )
	touch $(RADIUS_DIR)/.configure

build: $(RADIUS_DIR)/.configure
	mkdir -p "$(RADIUS_TARGET_DIR)"
	mkdir -p $(BT_STAGING_DIR)/etc
	mkdir -p $(BT_STAGING_DIR)/var
	mkdir -p $(BT_STAGING_DIR)/usr/lib
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	mkdir -p $(BT_STAGING_DIR)/usr/sbin
	mkdir -p $(BT_STAGING_DIR)/usr/include
	mkdir -p $(BT_STAGING_DIR)/usr/share/freeradius
	mkdir -p $(BT_STAGING_DIR)/etc/cron.daily
	mkdir -p $(BT_STAGING_DIR)/etc/cron.weekly
	mkdir -p $(BT_STAGING_DIR)/etc/init.d
#
	$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(RADIUS_DIR)
	$(MAKE) -C $(RADIUS_DIR) R="$(RADIUS_TARGET_DIR)" install
#
	$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(RADIUS_TARGET_DIR)"/usr/sbin/radiusd
	$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(RADIUS_TARGET_DIR)"/usr/sbin/radmin
	cp -f "$(RADIUS_TARGET_DIR)"/usr/sbin/radiusd "$(BT_STAGING_DIR)"/usr/sbin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/sbin/radmin "$(BT_STAGING_DIR)"/usr/sbin/
	$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(RADIUS_TARGET_DIR)"/usr/bin/radclient
	$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(RADIUS_TARGET_DIR)"/usr/bin/radeapclient
	$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(RADIUS_TARGET_DIR)"/usr/bin/radsniff
	$(BT_STRIP) $(BT_STRIP_BINOPTS) "$(RADIUS_TARGET_DIR)"/usr/bin/radwho
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radclient "$(BT_STAGING_DIR)"/usr/bin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radeapclient "$(BT_STAGING_DIR)"/usr/bin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radlast "$(BT_STAGING_DIR)"/usr/bin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radsniff "$(BT_STAGING_DIR)"/usr/bin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radtest "$(BT_STAGING_DIR)"/usr/bin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radwho "$(BT_STAGING_DIR)"/usr/bin/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/bin/radzap "$(BT_STAGING_DIR)"/usr/bin/
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) "$(RADIUS_TARGET_DIR)"/usr/lib/*.so
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) "$(RADIUS_TARGET_DIR)"/usr/lib/libltdl.so.3.1.4
	cp -f "$(RADIUS_TARGET_DIR)"/usr/lib/*.so "$(BT_STAGING_DIR)"/usr/lib/
	cp -f "$(RADIUS_TARGET_DIR)"/usr/lib/libltdl.so.3.1.4 "$(BT_STAGING_DIR)"/usr/lib/
	cp -a "$(RADIUS_TARGET_DIR)"/usr/include/* "$(BT_STAGING_DIR)"/usr/include/
	cp -a "$(RADIUS_TARGET_DIR)"/usr/share/freeradius/* "$(BT_STAGING_DIR)"/usr/share/freeradius/
	cp -a "$(RADIUS_TARGET_DIR)"/etc/* "$(BT_STAGING_DIR)"/etc/
	cp -a "$(RADIUS_TARGET_DIR)"/var/* "$(BT_STAGING_DIR)"/var/
	cp -aL radiusd.daily "$(BT_STAGING_DIR)"/etc/cron.daily/radiusd
	cp -aL radiusd.weekly "$(BT_STAGING_DIR)"/etc/cron.weekly/radiusd
	cp -aL radiusd.init "$(BT_STAGING_DIR)"/etc/init.d/radiusd

clean:
	rm -rf $(RADIUS_TARGET_DIR)
	$(MAKE) -C $(RADIUS_DIR) clean

srcclean: clean
	rm -rf $(RADIUS_DIR) 
	-rm DIRNAME
