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
	(cd $(DIR2) ;  CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" \
	./configure)

$(DIR2)/.build: $(DIR2)/Makefile
	$(MAKE) -C $(DIR2) \
		CC=$(TARGET_CC) LD=$(TARGET_LD)  \
		CFLAGS="$(BT_COPT_FLAGS) -Wall -DSYSV -fomit-frame-pointer \
		-fno-strength-reduce -I$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/include" \
		LDFLAGS="" 
	touch $(DIR2)/.build

$(DIR)/Makefile: $(DIR)/.source $(DIR2)/.build
	(cd $(DIR) ;  CC=$(TARGET_CC) LD=$(TARGET_LD) CFLAGS="$(BT_COPT_FLAGS)" \
	./configure --with-libol=../$(DIR2) --prefix=/ )

$(DIR)/.build: $(DIR)/Makefile
	mkdir -p $(TARGET_DIR)/sbin
	mkdir -p $(TARGET_DIR)/etc/init.d
	cp $(DIR2)/src/*.h $(DIR)/src/
	cp $(DIR2)/src/*.h.x $(DIR)/src/
	$(MAKE) -C $(DIR) \
		CC=$(TARGET_CC) LD=$(TARGET_LD)  \
		CFLAGS="$(BT_COPT_FLAGS) -Wall -DSYSV -fomit-frame-pointer -fno-strength-reduce \
		-I$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/include" LDFLAGS="" 
	cp -a  $(DIR)/src/syslog-ng  $(TARGET_DIR)/sbin
	cp -a  $(DIR)/debian/syslog-ng.conf  $(TARGET_DIR)/etc
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(DIR)/src/syslog-ng 
	cp -a  $(TARGET_DIR)/* $(BT_STAGING_DIR)/
	touch $(DIR)/.build

source: $(DIR)/.source

build: $(DIR)/Makefile $(DIR)/.build

clean:
	-rm $(DIR)/.build
	-$(MAKE) -C $(DIR) clean
  
srcclean:
	rm -rf $(DIR)