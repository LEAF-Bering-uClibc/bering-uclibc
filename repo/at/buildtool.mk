#############################################################
#
# buildtool makefile for at
#
#############################################################

SDIR:=at-3.1.10.2
TARGET_DIR:=$(BT_BUILD_DIR)/at


$(SDIR)/.source:
	zcat $(SOURCE) |  tar -xvf -
	cat $(PATCH1) | patch -p0 -d $(SDIR)
	cat $(PATCH2) | patch -p1 -d $(SDIR)
	touch $(SDIR)/.source

source: $(SDIR)/.source

$(SDIR)/Makefile: $(SDIR)/.source
	(cd $(SDIR) ; autoconf -i -f && \
	SENDMAIL=/sbin/sendmail \
	CFLAGS="$(CFLAGS) $(LDFLAGS)" \
	 ./configure --prefix=/usr --host=$(GNU_TARGET_NAME) \
	 --build=$(GNU_BUILD_NAME) \
	 --with-jobdir=/var/spool/cron/atjobs \
	 --with-atspool=/var/spool/cron/atspool)

$(SDIR)/.build: $(SDIR)/Makefile
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/bin
	mkdir -p $(TARGET_DIR)/usr/sbin
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/var/spool/cron/atjobs
#building in more than 1 thread fails
	$(MAKE) -C $(SDIR)

	cp -a $(SDIR)/atd $(TARGET_DIR)/usr/sbin
	cp -a $(SDIR)/atrun $(TARGET_DIR)/usr/sbin
	cp -a $(SDIR)/at $(TARGET_DIR)/usr/bin
	cp -a $(SDIR)/batch $(TARGET_DIR)/usr/bin
	touch $(TARGET_DIR)/var/spool/cron/atjobs/.SEQ

	cp -aL at.allow $(TARGET_DIR)/etc
	cp -aL at.init $(TARGET_DIR)/etc/init.d/atd
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/bin/at
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/usr/sbin/atd

	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)

build: $(SDIR)/.build

clean:
	-$(MAKE) -C $(SDIR) clean
	-rm $(SDIR)/.source $(SDIR)/.build $(SDIR)/Makefile

srcclean:
	rm -rf $(SDIR)
