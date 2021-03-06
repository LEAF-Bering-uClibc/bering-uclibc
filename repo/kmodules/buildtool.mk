#############################################################
#
# kmodules
#
#############################################################

ESCKEY:=$(shell echo "a\nb"|awk '/\\n/ {print "-e"}')

source:
	# nothing to be done

build:
	-rm -f package.cfg
	(for i in $(KARCHS); do \
	sed 's,#.*$$,\n,' modulelist.common >modulelist.$$i ; \
	[ "`echo $(KARCHS_PCIE) | awk '/(^|\W)'"$$i"'(\W|$$)/ {print "yes"}'`" = yes ] && \
		sed 's,#.*$$,\n,' modulelist.pcie >>modulelist.$$i ; \
	[ -f specific.$$i ] && sed 's,#.*$$,\n,' specific.$$i >>modulelist.$$i ; \
	depmod -a -b $(BT_STAGING_DIR) $(BT_KERNEL_RELEASE)-$$i ; \
	BT_STAGING_DIR=$(BT_STAGING_DIR) BT_KERNEL_RELEASE=$(BT_KERNEL_RELEASE)-$$i \
		sh $(BT_TOOLS_DIR)/getdep.sh `cat modulelist.$$i` >mod.$$i ; \
	[ -f files.$$i ] && rm -f files.$$i ; \
	for m in `cat mod.$$i`; do echo $(ESCKEY) "<File>\n\tSource\t\t= lib/modules/__KVER__-$$i/$$m \n\t\
	Filename\t= lib/modules/$$(echo $$m|sed 's,\([a-z0-9_-]*/\)\+,,')\n\t\
	Type\t\t= binary\n\tPermissions\t= 644\n</File>">>files.$$i; done; \
	for fw in `sed 's,#.*$$,\n,' firmware.common`; do [ -d $(BT_STAGING_DIR)/lib/firmware/$$fw ] && \
	echo $(ESCKEY) "<File>\n\tSource\t\t= lib/firmware/$$fw/*.bin\n\t\
	Filename\t= lib/firmware/$$fw/\n\t\
	Type\t\t= binary\n\tPermissions\t= 644\n</File>">>files.$$i; \
	[ -f $(BT_STAGING_DIR)/lib/firmware/$$fw ] && \
	echo $(ESCKEY) "<File>\n\tSource\t\t= lib/firmware/$$fw\n\t\
	Filename\t= lib/firmware/$$fw\n\t\
	Type\t\t= binary\n\tPermissions\t= 644\n</File>">>files.$$i; done; \
	echo $(ESCKEY) "?include <common.$$i>" >>package.cfg; \
	sed 's,##KARCH##,'"$$i"',g' common.tpl >common.$$i ; \
	done)

clean:
	# nothing to be done
