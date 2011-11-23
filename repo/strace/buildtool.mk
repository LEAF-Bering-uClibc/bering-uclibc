#############################################################
#
# buildtool makefile for strace
#
#############################################################

include $(MASTERMAKEFILE)

STRACE_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(STRACE_SOURCE) 2>/dev/null )
ifeq ($(STRACE_DIR),)
STRACE_DIR:=$(shell cat DIRNAME)
endif

STRACE_TARGET_DIR:=$(BT_BUILD_DIR)/strace

# Option settings for 'configure':
#   Move default install from /usr/local to /usr
CONFOPTS:=--prefix=/usr

$(STRACE_DIR)/.source:
	bzcat $(STRACE_SOURCE) | tar -xvf -
	echo $(STRACE_DIR) > DIRNAME
	touch $(STRACE_DIR)/.source

source: $(STRACE_DIR)/.source

$(STRACE_DIR)/.configure: $(STRACE_DIR)/.source
	( cd $(STRACE_DIR); ./configure $(CONFOPTS) );
	touch $(STRACE_DIR)/.configure

$(STRACE_DIR)/.build: $(STRACE_DIR)/.configure
	mkdir -p $(STRACE_TARGET_DIR)
	$(MAKE) -C $(STRACE_DIR)
	$(MAKE) DESTDIR=$(STRACE_TARGET_DIR) -C $(STRACE_DIR) install
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(STRACE_TARGET_DIR)/usr/bin/strace
	cp -ra $(STRACE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(STRACE_DIR)/.build

build: $(STRACE_DIR)/.build

clean:
	-rm $(STRACE_DIR)/.build
	rm -rf $(STRACE_TARGET_DIR)
	$(MAKE) -C $(STRACE_DIR) clean

srcclean:
	rm -rf $(STRACE_DIR)
	-rm DIRNAME

