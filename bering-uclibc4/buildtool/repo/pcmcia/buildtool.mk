#############################################################
#
# PCMCIA 
#
#############################################################

include $(MASTERMAKEFILE)

PCMCIA_DIR:=pcmciautils-017
PCMCIA_TARGET_DIR:=$(BT_BUILD_DIR)/pcmcia
STRIP_OPTIONS=-s --remove-section=.note --remove-section=.comment


$(PCMCIA_DIR)/.source:
	bzcat $(PCMCIA_SOURCE) | tar -xvf -
	touch $(PCMCIA_DIR)/.source
	
$(PCMCIA_DIR)/.configured: $(PCMCIA_DIR)/.source
#	(cd $(PCMCIA_DIR) ; ./Configure --kernel="$(BT_LINUX_DIR)" \
#		--notrust --cardbus --nopnp --apm --nox11 --srctree --noprompt --sysv \
#		--arch=i386 \
#		--ucc=$(TARGET_CC) \
#		--kcc=$(TARGET_CC) \
#		--ld=$(TARGET_LD)	);
	touch $(PCMCIA_DIR)/.configured
	
	
source: $(PCMCIA_DIR)/.source

#build: $(PCMCIA_DIR)/.configured
build: $(PCMCIA_DIR)/.configured
	-mkdir -p $(PCMCIA_TARGET_DIR)
	-mkdir -p $(PCMCIA_TARGET_DIR)/sbin
	-mkdir -p $(PCMCIA_TARGET_DIR)/etc/pcmcia
#	-mkdir -p $(PCMCIA_TARGET_DIR)/etc/default
#	-mkdir -p $(PCMCIA_TARGET_DIR)/etc/init.d
	make -C $(PCMCIA_DIR) all 	
	-$(BT_STRIP) $(STRIP_OPTIONS) $(PCMCIA_DIR)/cardmgr/cardmgr
	-$(BT_STRIP) $(STRIP_OPTIONS) $(PCMCIA_DIR)/cardmgr/cardctl
#	cp -a config $(PCMCIA_TARGET_DIR)/etc/pcmcia
#	cp -a network $(PCMCIA_TARGET_DIR)/etc/pcmcia
#	cp -a shared $(PCMCIA_TARGET_DIR)/etc/pcmcia
	cp -a config.opts $(PCMCIA_TARGET_DIR)/etc/pcmcia
#	cp -a serial $(PCMCIA_TARGET_DIR)/etc/pcmcia
#	cp -a $(PCMCIA_DIR)/etc/cis/*.dat $(PCMCIA_TARGET_DIR)/etc/pcmcia/cis
#	cp -a pcmcia.default $(PCMCIA_TARGET_DIR)/etc/default/pcmcia
#	cp -a pcmcia.init $(PCMCIA_TARGET_DIR)/etc/init.d/pcmcia
#	cp -a $(PCMCIA_DIR)/cardmgr/cardmgr $(PCMCIA_TARGET_DIR)/sbin 
#	cp -a $(PCMCIA_DIR)/cardmgr/cardctl $(PCMCIA_TARGET_DIR)/sbin 
#	cp -a $(PCMCIA_DIR)/cardmgr/cardmgr $(PCMCIA_TARGET_DIR)/sbin 
	cp -a $(PCMCIA_DIR)/pccardctl $(PCMCIA_TARGET_DIR)/sbin 
	cp -a $(PCMCIA_DIR)/pcmcia-check-broken-cis $(PCMCIA_TARGET_DIR)/sbin 
	cp -a $(PCMCIA_DIR)/pcmcia-socket-startup $(PCMCIA_TARGET_DIR)/sbin 
	cp -a $(PCMCIA_TARGET_DIR)/* $(BT_STAGING_DIR)	
	touch $(PCMCIA_DIR)/.build	

clean:
	-make -C $(PCMCIA_DIR) clean
	rm -rf $(PCMCIA_TARGET_DIR)
	rm -f $(PCMCIA_DIR)/.build
	rm -f $(PCMCIA_DIR)/.configured
	
srcclean:
	rm -rf $(PCMCIA_DIR)
	
