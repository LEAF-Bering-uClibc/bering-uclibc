# makefile for ez-ipupdate
include $(MASTERMAKEFILE)

EZ_IPUPDATE_DIR:=ez-ipupdate-3.0.11b8
EZ_IPUPDATE_TARGET_DIR:=$(BT_BUILD_DIR)/ez-ipupdate

$(EZ_IPUPDATE_DIR)/.source:
	zcat $(EZ_IPUPDATE_SOURCE) | tar -xvf -
	zcat $(EZ_IPUPDATE_PATCH1) | patch -d $(EZ_IPUPDATE_DIR) -p1
	cat $(EZ_IPUPDATE_PATCH2) | patch -d $(EZ_IPUPDATE_DIR) -p1
	touch $(EZ_IPUPDATE_DIR)/.source

source: $(EZ_IPUPDATE_DIR)/.source

$(EZ_IPUPDATE_DIR)/.configured: $(EZ_IPUPDATE_DIR)/.source
	(cd $(EZ_IPUPDATE_DIR) ; autoreconf -i -f && \
	./configure --prefix=/usr/ \
	--host=$(GNU_TARGET_NAME) )
	touch $(EZ_IPUPDATE_DIR)/.configured

$(EZ_IPUPDATE_DIR)/.build: $(EZ_IPUPDATE_DIR)/.configured
	mkdir -p $(EZ_IPUPDATE_TARGET_DIR)
	mkdir -p $(EZ_IPUPDATE_TARGET_DIR)/etc/init.d
	make $(MAKEOPTS) -C $(EZ_IPUPDATE_DIR) DESTDIR=$(EZ_IPUPDATE_TARGET_DIR) install
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(EZ_IPUPDATE_TARGET_DIR)/usr/bin/ez-ipupdate
	cp -aL ez-ipupd $(EZ_IPUPDATE_TARGET_DIR)/etc/init.d/
	cp -aL ez-ipupd.conf $(EZ_IPUPDATE_TARGET_DIR)/etc/
	cp -a $(EZ_IPUPDATE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(EZ_IPUPDATE_DIR)/.build

build: $(EZ_IPUPDATE_DIR)/.build

clean:
	make -C $(EZ_IPUPDATE_DIR) clean
	rm -rf $(EZ_IPUPDATE_TARGET_DIR)
	rm $(EZ_IPUPDATE_DIR)/.build
	rm $(EZ_IPUPDATE_DIR)/.configured

srcclean: clean
	rm -rf $(EZ_IPUPDATE_DIR)
	rm $(EZ_IPUPDATE_DIR)/.source
