# makefile for etc.lrp

ETC_DIR=.
ETC_TARGET_DIR:=$(BT_BUILD_DIR)/etc

$(ETC_DIR)/.source:
	touch $(ETC_DIR)/.source

source: $(ETC_DIR)/.source

$(ETC_DIR)/.build: $(ETC_DIR)/.source
	mkdir -p $(ETC_TARGET_DIR)
	mkdir -p $(ETC_TARGET_DIR)/etc
	mkdir -p $(ETC_TARGET_DIR)/etc/cron.d
	mkdir -p $(ETC_TARGET_DIR)/etc/cron.daily
	mkdir -p $(ETC_TARGET_DIR)/etc/default
	mkdir -p $(ETC_TARGET_DIR)/etc/syslog-ng
	mkdir -p $(ETC_TARGET_DIR)/etc/init.d
	mkdir -p $(ETC_TARGET_DIR)/etc/network/if-up.d
	mkdir -p $(ETC_TARGET_DIR)/etc/network/if-pre-up.d
	mkdir -p $(ETC_TARGET_DIR)/etc/network/if-down.d
	mkdir -p $(ETC_TARGET_DIR)/etc/network/if-post-down.d
	cp -aL crontab $(ETC_TARGET_DIR)/etc
	cp -aL fstab $(ETC_TARGET_DIR)/etc
	cp -aL group $(ETC_TARGET_DIR)/etc
	cp -aL gshadow $(ETC_TARGET_DIR)/etc
	cp -aL hostname $(ETC_TARGET_DIR)/etc
	cp -aL hosts $(ETC_TARGET_DIR)/etc
	cp -aL hosts.allow $(ETC_TARGET_DIR)/etc
	cp -aL hosts.deny $(ETC_TARGET_DIR)/etc
	cp -aL inetd.conf $(ETC_TARGET_DIR)/etc
	cp -aL inittab $(ETC_TARGET_DIR)/etc
	cp -aL lrp.conf $(ETC_TARGET_DIR)/etc
	cp -aL networks $(ETC_TARGET_DIR)/etc
	cp -aL passwd $(ETC_TARGET_DIR)/etc
ifdef PLATFORM_EDITOR
	cp -aL profile-$(PLATFORM_EDITOR) $(ETC_TARGET_DIR)/etc/profile
else
	cp -aL profile $(ETC_TARGET_DIR)/etc/profile
endif
	cp -aL protocols $(ETC_TARGET_DIR)/etc
	cp -aL resolv.conf $(ETC_TARGET_DIR)/etc
	cp -aL rpc $(ETC_TARGET_DIR)/etc
	cp -aL securetty $(ETC_TARGET_DIR)/etc
	cp -aL services $(ETC_TARGET_DIR)/etc
	cp -aL shadow  $(ETC_TARGET_DIR)/etc
	cp -aL shells $(ETC_TARGET_DIR)/etc
	cp -aL sysctl.conf $(ETC_TARGET_DIR)/etc
	cp -aL syslog-ng.conf $(ETC_TARGET_DIR)/etc/syslog-ng
	cp -aL TZ $(ETC_TARGET_DIR)/etc
	cp -aL multicron $(ETC_TARGET_DIR)/etc/cron.d
	cp -aL multicron-d $(ETC_TARGET_DIR)/etc/cron.daily
	cp -aL rcS.default $(ETC_TARGET_DIR)/etc/default/rcS
	cp -aL interfaces $(ETC_TARGET_DIR)/etc/network
	cp -aL bootmisc.sh $(ETC_TARGET_DIR)/etc/init.d
	cp -aL checkroot.sh $(ETC_TARGET_DIR)/etc/init.d
	cp -aL cron $(ETC_TARGET_DIR)/etc/init.d
	cp -aL hostname.sh $(ETC_TARGET_DIR)/etc/init.d
	cp -aL hwclock $(ETC_TARGET_DIR)/etc/init.d
	cp -aL ifupdown $(ETC_TARGET_DIR)/etc/init.d
	cp -aL inetd $(ETC_TARGET_DIR)/etc/init.d
	cp -aL local $(ETC_TARGET_DIR)/etc/init.d
	cp -aL local.start $(ETC_TARGET_DIR)/etc/default
	cp -aL local.stop $(ETC_TARGET_DIR)/etc/default
	cp -aL mountall.sh $(ETC_TARGET_DIR)/etc/init.d
	cp -aL networking $(ETC_TARGET_DIR)/etc/init.d
	cp -aL procps.sh $(ETC_TARGET_DIR)/etc/init.d
	cp -aL rc $(ETC_TARGET_DIR)/etc/init.d
	cp -aL rcS $(ETC_TARGET_DIR)/etc/init.d
	cp -aL rmnologin $(ETC_TARGET_DIR)/etc/init.d
	cp -aL syslog-ng $(ETC_TARGET_DIR)/etc/init.d
	cp -aL umountfs $(ETC_TARGET_DIR)/etc/init.d
	cp -aL urandom $(ETC_TARGET_DIR)/etc/init.d
	cp -aL watchdog $(ETC_TARGET_DIR)/etc/init.d
	cp -aL ifenslave.up $(ETC_TARGET_DIR)/etc/network/if-up.d/ifenslave
	cp -aL ip.up $(ETC_TARGET_DIR)/etc/network/if-up.d/ip
	cp -aL ifenslave.down $(ETC_TARGET_DIR)/etc/network/if-down.d/ifenslave
	cp -aL vlan.up $(ETC_TARGET_DIR)/etc/network/if-pre-up.d/vlan
	cp -aL vlan.down $(ETC_TARGET_DIR)/etc/network/if-post-down.d/vlan
	cp -aL mdev.conf $(ETC_TARGET_DIR)/etc/
	cp -a $(ETC_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ETC_DIR)/.build

build: $(ETC_DIR)/.build

clean:
	rm -rf $(ETC_TARGET_DIR)
	rm -f $(ETC_DIR)/.build

srcclean: clean
	rm -f $(ETC_DIR)/.source
