# makefile for ppp, ppp-filter, pppoe and pppoatm

PPP_SCRIPT_TARGET_DIR:=$(BT_BUILD_DIR)/ppp-scripts

source:

build:
	mkdir -p $(PPP_SCRIPT_TARGET_DIR)/etc/ppp
	cp -aL ip-up $(PPP_SCRIPT_TARGET_DIR)/etc/ppp
	cp -aL ip-mod $(PPP_SCRIPT_TARGET_DIR)/etc/ppp
	cp -aL ip-down $(PPP_SCRIPT_TARGET_DIR)/etc/ppp
	cp -aL ipv6-up $(PPP_SCRIPT_TARGET_DIR)/etc/ppp
	cp -aL ipv6-down $(PPP_SCRIPT_TARGET_DIR)/etc/ppp
	cp -a $(PPP_SCRIPT_TARGET_DIR)/* $(BT_STAGING_DIR)

clean:
	rm -rf $(PPP_SCRIPT_TARGET_DIR)

srcclean: clean
