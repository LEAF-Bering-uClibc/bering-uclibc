# makefile for initrd
include $(MASTERMAKEFILE)

INITRD_DIR=.
INITRD_TARGET_DIR:=$(BT_BUILD_DIR)/config
ESCKEY=$(shell echo "a\nb"|awk '/\\n/ {print "-e"}')

source:

$(INITRD_DIR)/.build:
	mkdir -p $(INITRD_TARGET_DIR)
	mkdir -p $(INITRD_TARGET_DIR)/var/lib/lrpkg
	mkdir -p $(INITRD_TARGET_DIR)/boot/etc
	mkdir -p $(INITRD_TARGET_DIR)/sbin

	echo $(ESCKEY) "isofs\nvfat">$(INITRD_TARGET_DIR)/boot/etc/modules
	-rm -f package.cfg
	(for a in $(KARCHS); do \
	sed 's,#.*$$,\n,' modulelist.common >modulelist.$$a ; \
	[ -f specific.$$a ] && sed 's,#.*$$,\n,' specific.$$a >>modulelist.$$a ; \
	BT_STAGING_DIR=$(BT_STAGING_DIR) BT_KERNEL_RELEASE=$(BT_KERNEL_RELEASE)-$$a \
		    sh $(BT_TOOLS_DIR)/getdep.sh `cat modulelist.$$a` >mod ; \
	[ -f files.$$a ] && rm -f files.$$a ; \
	for m in `cat mod`; do echo $(ESCKEY) "<File>\n\tSource\t\t= lib/modules/__KVER__-$$a/$$m \n\t\
	Filename\t= lib/modules/$$(echo $$m|sed 's,\([a-z0-9]*/\)\+,,')\n\t\
	Type\t\t= binary\n\tType\t\t= module\n\tPermissions\t= 644\n</File>">>files.$$a; done; \
	echo $(ESCKEY) "#include <common.$$a>" >>package.cfg; \
	perl -p -e "s,##ARCH##,$$a,g" common.tpl >common.$$a ; \
	done)

	cp -aL README $(INITRD_TARGET_DIR)/boot/etc
	cp -aL root.linuxrc $(INITRD_TARGET_DIR)/var/lib/lrpkg
	cp -aL root.helper $(INITRD_TARGET_DIR)/var/lib/lrpkg
	cp -aL hotplug.sh $(INITRD_TARGET_DIR)/sbin
	cp -a $(INITRD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(INITRD_DIR)/.build

build: $(INITRD_DIR)/.build

clean:
	rm -rf $(INITRD_TARGET_DIR)
	rm -f $(INITRD_DIR)/.build
	rm -f $(INITRD_DIR)/.configured

srcclean: clean
	rm -f $(INITRD_DIR)/.source
	rm -f $(INITRD_DIR)/root.linuxrc
	rm -f $(INITRD_DIR)/modules
	rm -f $(INITRD_DIR)/README

