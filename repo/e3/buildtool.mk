#############################################################
#
# e3
#
#############################################################

E3_DIR:=e3-2.8
E3_TARGET_DIR:=$(BT_BUILD_DIR)/e3

$(E3_DIR)/.source:
	zcat $(E3_SOURCE) |  tar -xvf -
	cp $(E3_HEADER) $(E3_DIR)
	touch $(E3_DIR)/.source

$(E3_DIR)/.build: $(E3_DIR)/.source
	mkdir -p $(E3_TARGET_DIR)/bin
	$(MAKE) $(E3_MAKETARGET) $(MAKEOPTS) -C $(E3_DIR) CC=$(TARGET_CC)  PREFIX=/usr COMPRESS= EXMODE=SED
	cp $(E3_DIR)/e3 $(E3_TARGET_DIR)/bin
	cp -a $(E3_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(E3_DIR)/.build

source: $(E3_DIR)/.source

build: $(E3_DIR)/.build

clean:
	-rm $(E3_DIR)/.build
	-$(MAKE) -C $(E3_DIR) clean

srcclean:
	rm -rf $(E3_DIR)
