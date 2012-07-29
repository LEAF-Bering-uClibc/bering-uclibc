# makefile for qos-htb
include $(MASTERMAKEFILE)

QOS-HTB_DIR=.
QOS-HTB_TARGET_DIR:=$(BT_BUILD_DIR)/qos-htb

$(QOS-HTB_DIR)/.source:
	zcat $(QOS-HTB_SOURCE) > htb.init-v0.8.5
	zcat $(QOS-HTB_ASHPATCH) | patch -d $(QOS-HTB_DIR) -p1
	touch $(QOS-HTB_DIR)/.source

source: $(QOS-HTB_DIR)/.source

$(QOS-HTB_DIR)/.build:
	mkdir -p $(QOS-HTB_TARGET_DIR)
	mkdir -p $(QOS-HTB_TARGET_DIR)/sbin
	mkdir -p $(QOS-HTB_TARGET_DIR)/etc/init.d
	cp -aL htb.init-v0.8.5 $(QOS-HTB_TARGET_DIR)/sbin/htb.init
	cp -aL htb.sysconfig $(QOS-HTB_TARGET_DIR)/sbin
	cp -aL htb.init $(QOS-HTB_TARGET_DIR)/etc/init.d
	cp -a $(QOS-HTB_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(QOS-HTB_DIR)/.build

build: $(QOS-HTB_DIR)/.build

clean:
	rm -rf $(QOS-HTB_TARGET_DIR)
	rm $(QOS-HTB_DIR)/.build
	rm $(QOS-HTB_DIR)/.configured

srcclean: clean
	rm -rf $(QOS-HTB_DIR)
	rm $(QOS-HTB_DIR)/.source
