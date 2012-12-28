# makefile for initmod

INITMOD_DIR=.
ESCKEY:=$(shell echo "a\nb"|awk '/\\n/ {print "-e"}')

source:

$(INITMOD_DIR)/.build:
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
	echo $(ESCKEY) "?include <common.$$a>" >>package.cfg; \
	perl -p -e "s,##ARCH##,$$a,g" common.tpl >common.$$a ; \
	done)

	touch $(INITMOD_DIR)/.build

build: $(INITMOD_DIR)/.build

clean:
	for a in $(KARCHS); do \
		rm -f $(INITMOD_DIR)/modulelist.$$a ; \
		rm -f $(INITMOD_DIR)/files.$$a ;      \
		rm -f $(INITMOD_DIR)/common.$$a ;     \
	done
	rm -f $(INITMOD_DIR)/mod
	rm -f $(INITMOD_DIR)/package.cfg
	rm -f $(INITMOD_DIR)/.build

srcclean: clean
	rm -f $(INITMOD_DIR)/.source
