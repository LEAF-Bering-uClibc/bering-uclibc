# makefile for radiusd-cistron
include $(MASTERMAKEFILE)

RADIUS_DIR:=radcoad-0.1.2
RADIUS_TARGET_DIR:=$(BT_BUILD_DIR)/radcoad

$(RADIUS_DIR)/.source:
	zcat $(RADIUS_SOURCE) | tar -xvf -
	touch $(RADIUS_DIR)/.source

source: $(RADIUS_DIR)/.source

$(RADIUS_DIR)/.build: $(RADIUS_DIR)/.source
	mkdir -p $(RADIUS_TARGET_DIR)
	mkdir -p $(RADIUS_TARGET_DIR)/usr/bin
	mkdir -p $(RADIUS_TARGET_DIR)/usr/sbin
	mkdir -p $(RADIUS_TARGET_DIR)/etc/cron.daily
	mkdir -p $(RADIUS_TARGET_DIR)/etc/cron.monthly
	mkdir -p $(RADIUS_TARGET_DIR)/etc/init.d
	mkdir -p $(RADIUS_TARGET_DIR)/etc/radcoadb
	make CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS) -Wall -g" \
	LIBS= LSHADOW= LCRYPT=-lcrypt SHAREDIR=/etc/raddb -C $(RADIUS_DIR)/src
	-$(BT_STRIP) -s --remove-section=.note --remove-section=.comment $(RADIUS_DIR)/src/radcoad

	cp -a $(RADIUS_DIR)/src/radcoad $(RADIUS_TARGET_DIR)/usr/sbin
	cp -aL radcoad.init $(RADIUS_TARGET_DIR)/etc/init.d/radcoad

	# Install the config files
	cp $(RADIUS_DIR)/radcoadb/* $(RADIUS_TARGET_DIR)/etc/radcoadb

	cp -a $(RADIUS_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(RADIUS_DIR)/.build

build: $(RADIUS_DIR)/.build
                                                                                         
clean:
	make -C $(RADIUS_DIR)/src clean
	rm -rf $(RADIUS_TARGET_DIR)
	rm -f $(RADIUS_DIR)/.build
                                                                                                                 
srcclean: clean
	rm -rf $(RADIUS_DIR) 
	rm -f $(RADIUS_DIR)/.source