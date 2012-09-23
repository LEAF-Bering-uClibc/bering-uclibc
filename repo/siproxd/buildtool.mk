#############################################################
#
# siproxd
#
#############################################################

SIPROXD_DIR:=siproxd-0.5.13
SIPROXD_TARGET_DIR:=$(BT_BUILD_DIR)/siproxd


$(SIPROXD_DIR)/.source:
	zcat $(SIPROXD_SOURCE) |  tar -xvf -
	zcat $(SIPROXD_PATCH1) | patch -d $(SIPROXD_DIR) -p1
	touch $(SIPROXD_DIR)/.source

$(SIPROXD_DIR)/.configured: $(SIPROXD_DIR)/.source
	(cd $(SIPROXD_DIR); rm -f Makefile.in aclocal.m4; autoreconf -i -f && \
	./configure --host=$(GNU_TARGET_NAME) \
	--build=$(GNU_BUILD_NAME) \
	--prefix=/usr );
	#--with-extra-libs=$(BT_STAGING_DIR)/usr );
	touch $(SIPROXD_DIR)/.configured

$(SIPROXD_DIR)/.build: $(SIPROXD_DIR)/.configured
	mkdir -p $(SIPROXD_TARGET_DIR)
	mkdir -p $(SIPROXD_TARGET_DIR)/usr/sbin
	mkdir -p $(SIPROXD_TARGET_DIR)/etc/init.d
	$(MAKE) $(MAKEOPTS) -C $(SIPROXD_DIR)
	cp -a  $(SIPROXD_DIR)/src/siproxd $(SIPROXD_TARGET_DIR)/usr/sbin
	cp -aL  siproxd.init $(SIPROXD_TARGET_DIR)/etc/init.d/siproxd
	cp -aL  siproxd_passwd.cfg $(SIPROXD_TARGET_DIR)/etc/
	cp -aL  siproxd.conf $(SIPROXD_TARGET_DIR)/etc/
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(SIPROXD_TARGET_DIR)/usr/sbin/*
	cp -a $(SIPROXD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(SIPROXD_DIR)/.build

source: $(SIPROXD_DIR)/.source

build: $(SIPROXD_DIR)/.build

clean:
	-rm $(SIPROXD_DIR)/.build
	-$(MAKE) -C $(SIPROXD_DIR) clean
	-rm -rf $(SIPROXD_TARGET_DIR)

srcclean:
	rm -rf $(SIPROXD_DIR)
