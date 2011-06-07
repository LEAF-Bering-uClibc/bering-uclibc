#############################################################
#
# buildtool makefile for at
#
#############################################################

include $(MASTERMAKEFILE)
SDIR:=at-3.1.10.2
TARGET_DIR:=$(BT_BUILD_DIR)/at


$(SDIR)/.source: 
	zcat $(SOURCE) |  tar -xvf -
	cat getloadavg.c.patch | patch -p0 -d $(SDIR)
#	cp Makefile $(SDIR)
#	cp config.h $(SDIR)
	touch $(SDIR)/.source

source: $(SDIR)/.source

$(SDIR)/Makefile: $(SDIR)/.source
	(cd $(SDIR) ; CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" \
	LD=$(TARGET_LD) SENDMAIL=/sbin/sendmail ./configure --prefix=/usr \
	--with-jobdir=/var/spool/cron/atjobs \
	--with-atspool=/var/spool/cron/atspool)

$(SDIR)/.build: $(SDIR)/Makefile
	$(MAKE) CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" \
		LD=$(TARGET_LD) -C $(SDIR)
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/bin
	mkdir -p $(TARGET_DIR)/usr/sbin
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/var/spool/cron/atjobs

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
