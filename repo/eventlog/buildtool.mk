#############################################################
#
# buildtool makefile for eventlog
#
#############################################################

include $(MASTERMAKEFILE)

EVENTLOG_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(EVENTLOG_SOURCE) 2>/dev/null )
ifeq ($(EVENTLOG_DIR),)
EVENTLOG_DIR:=$(shell cat DIRNAME)
endif
EVENTLOG_TARGET_DIR:=$(BT_BUILD_DIR)/eventlog

$(EVENTLOG_DIR)/.source:
	zcat $(EVENTLOG_SOURCE) | tar -xvf -
	echo $(EVENTLOG_DIR) > DIRNAME
	touch $(EVENTLOG_DIR)/.source

source: $(EVENTLOG_DIR)/.source

$(EVENTLOG_DIR)/.configured: $(EVENTLOG_DIR)/.source
	(cd $(EVENTLOG_DIR) ; ./configure \
	--prefix=/usr \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME))
	touch $(EVENTLOG_DIR)/.configured

$(EVENTLOG_DIR)/.build: $(EVENTLOG_DIR)/.configured
	mkdir -p $(EVENTLOG_TARGET_DIR)
	make $(MAKEOPTS) -C $(EVENTLOG_DIR) all
	make DESTDIR=$(EVENTLOG_TARGET_DIR) -C $(EVENTLOG_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(EVENTLOG_TARGET_DIR)/usr/lib/*
	cp -a -f $(EVENTLOG_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(EVENTLOG_DIR)/.build

build: $(EVENTLOG_DIR)/.build

clean:
	make -C $(EVENTLOG_DIR) clean
	rm -rf $(EVENTLOG_TARGET_DIR)
	rm -rf $(EVENTLOG_DIR)/.build
	rm -rf $(EVENTLOG_DIR)/.configured

srcclean: clean
	rm -rf $(EVENTLOG_DIR)
	rm -rf $(EVENTLOG_DIR)/.source
	-rm DIRNAME
