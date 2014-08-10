# buildtool make file for buildenv
#
# Note that this is some kind of a hack as you normally should do things
# not the way they are handled here


LINUX_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(KERNEL_BASE_SOURCE) 2>/dev/null )

unexport CROSS_COMPILE

.source:
	$(BT_SETUP_BUILDDIR) -v $(KERNEL_BASE_SOURCE)
	xzcat $(UPDATE_KERNEL_SOURCE_PATCH) | patch -p1 -s -d $(LINUX_DIR)
	ln -s $(LINUX_DIR) linux
	cat $(KERNEL_PATCH1) | patch -d $(LINUX_DIR)/lib -p0
	cat $(KERNEL_PATCH2) | patch -d $(LINUX_DIR) -p1
#	cat $(KERNEL_PATCH3) | patch -d $(LINUX_DIR) -p1
	cat $(KERNEL_PATCH4) | patch -d $(LINUX_DIR) -p1
#	cat $(KERNEL_PATCH6) | patch -d $(LINUX_DIR) -p1
#	cat $(KERNEL_PATCH_BCMRPI) | patch -d $(LINUX_DIR) -p1
	xzcat $(WIRELESS_REGDB) | tar -xvf -
	cp $(WIRELESS_REGDB:.tar.xz=)/db.txt linux/net/wireless
	mkdir -p $(BT_TOOLCHAIN_DIR)/usr
	touch .source

#	ARCH=$(ARCH) $(MAKE) -C linux-$$i include/linux/version.h headers_install && \

.configured: .source
	(for i in $(KARCHS); do \
	echo $$i && \
	patch -i $(LINUX_CONFIG)-$$i.patch -o $(LINUX_CONFIG)-$$i $(LINUX_CONFIG) && \
	mkdir -p linux-$$i && cp $(LINUX_CONFIG)-$$i linux-$$i/.config && \
	ARCH=$(ARCH) $(MAKE) -C $(LINUX_DIR) O=../linux-$$i oldconfig || \
	exit 1; done)
	touch .configured

source: .source

build: 	.configured
	echo "nothing done here right now, all done by buildenv and kernel package"

headers: .configured
	ARCH=$(ARCH) $(MAKE) -C linux$(FIRSTKARCH) headers_install_all INSTALL_HDR_PATH=$(BT_HEADERS_DIR)

clean:
	-rm -f .configured
	for i in $(KARCHS); do rm -rf linux-$$i; done

srcclean: clean
	rm -f linux
	rm -rf $(LINUX_DIR)
	rm -rf wireless-regdb-*/
	rm -f .source
