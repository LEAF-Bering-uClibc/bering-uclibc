#####################################################
#
# haserl setup
#
#####################################################
include $(MASTERMAKEFILE)

#####################################################

#####################################################
# Build haserl

SOURCE_DIR:=$(shell basename `tar tzf $(SOURCE_TARBALL) | head -1`)
HASERL_TARGET_DIR:=$(BT_BUILD_DIR)/haserl

.source:
	zcat $(SOURCE_TARBALL) | tar -xvf -
	echo $(SOURCE_DIR) > .source

source: .source

.configured: .source
	(cd $(SOURCE_DIR);  ./configure --prefix=/usr --host=$(GNU_TARGET_NAME) --build=$(GNU_BUILD_NAME))
	touch .configured

.build: .configured
	mkdir -p $(HASERL_TARGET_DIR)
	mkdir -p $(HASERL_TARGET_DIR)/usr/bin
	make $(MAKEOPTS) -C $(SOURCE_DIR) all
	cp -a $(SOURCE_DIR)/src/haserl $(HASERL_TARGET_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(HASERL_TARGET_DIR)/usr/bin/*
	cp -a $(HASERL_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build


clean:
	make -C `cat .source` clean
	rm -rf $(HASERL_TARGET_DIR)
	rm -rf .build
	rm -rf .configured

srcclean: clean
	rm -rf `cat .source`
	rm -rf .source
