#############################################################
#
# sysklogd
#
# $Id: buildtool.mk,v 1.2 2010/11/01 11:02:10 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
DIR:=syslog-ng-1.6.12
DIR2:=$(DIR)/libol-0.3.18
TARGET_DIR:=$(BT_BUILD_DIR)/syslog-ng


$(DIR)/.source:
	zcat $(SOURCE) |  tar -xvf -
	cat $(PATCH1) | patch -d $(DIR) -p1
	touch $(DIR)/.source

$(DIR2)/Makefile: $(DIR2)
	(cd $(DIR2) ; ./configure \
	--host=$(GNU_TARGET_NAME)\
	--build=$(GNU_BUILD_NAME))

$(DIR2)/.build: $(DIR2)/Makefile
	$(MAKE) -C $(DIR2)
	touch $(DIR2)/.build

$(DIR)/Makefile: $(DIR)/.source $(DIR2)/.build
	(cd $(DIR) ; ./configure --with-libol=../$(DIR2) --prefix=/ \
	--host=$(GNU_TARGET_NAME)\
	--build=$(GNU_BUILD_NAME))

$(DIR)/.build: $(DIR)/Makefile
	mkdir -p $(TARGET_DIR)/sbin
	mkdir -p $(TARGET_DIR)/etc/init.d
	cp $(DIR2)/src/*.h $(DIR)/src/
	cp $(DIR2)/src/*.h.x $(DIR)/src/
	$(MAKE) $(MAKEOPTS) -C $(DIR)
	cp -a  $(DIR)/src/syslog-ng  $(TARGET_DIR)/sbin
	cp -a  $(DIR)/debian/syslog-ng.conf  $(TARGET_DIR)/etc
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TARGET_DIR)/sbin/*
	cp -a  $(TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DIR)/.build

source: $(DIR)/.source

build: $(DIR)/Makefile $(DIR)/.build

clean:
	-rm $(DIR)/.build
	-$(MAKE) -C $(DIR) clean

srcclean:
	rm -rf $(DIR)
