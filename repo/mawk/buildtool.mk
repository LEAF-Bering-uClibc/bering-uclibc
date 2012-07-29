#############################################################
#
# buildtool makefile for mawk
#
#############################################################

include $(MASTERMAKEFILE)

MAWK_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null )
ifeq ($(MAWK_DIR),)
MAWK_DIR:=$(shell cat DIRNAME)
endif
MAWK_TARGET_DIR:=$(BT_BUILD_DIR)/mawk

.source:
	zcat $(SOURCE) | tar -xvf -
	echo $(MAWK_DIR) > DIRNAME
	# Hack Makefile.in for cross-compiled build
	# Program makescan.exe needs to execute on the *build* host
	perl -i -p -e "s,^.* -o makescan\.exe .*,	gcc \\$(CPPFLAGS) -o makescan.exe makescan.c," ${MAWK_DIR}/Makefile.in
	touch .source

source: .source

.configure: .source
	(cd $(MAWK_DIR) ; CC=$(TARGET_CC) ./configure --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	touch .configure

.build: .configure
	mkdir -p $(MAWK_TARGET_DIR)
	mkdir -p $(MAWK_TARGET_DIR)/usr/bin
	perl -i -p -e "s,trap 0,trap - 0,g" ${MAWK_DIR}/test/mawktest
	perl -i -p -e "s,\strap\s*0,trap - 0,g" ${MAWK_DIR}/test/fpe_test
	# Multi-threaded make fails so don't specify $(MAKEOPTS)
	make -C $(MAWK_DIR) mawk
	cp -a $(MAWK_DIR)/mawk $(MAWK_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(MAWK_TARGET_DIR)/usr/bin/*
	cp -a $(MAWK_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	make -C $(MAWK_DIR) clean
	rm -rf $(MAWK_TARGET_DIR)
	rm -f .build
	rm -f .configure

srcclean: clean
	rm -rf $(MAWK_DIR)
	rm DIRNAME
	rm -f .source
