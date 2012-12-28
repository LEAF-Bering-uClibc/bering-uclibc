# buildtool make file for kernel (pseudo package)
#
# Note that this is some kind of a hack the linux source
# does not build the kernel, but only unpacks it as the headers
# are needed by some programs
#
# so a ./buildtool2.pl build kernel (we in here ) must do it

ESCKEY:=$(shell echo "a\nb"|awk '/\\n/ {print "-e"}')

LINUX_BUILDDIR=$(BT_BUILD_DIR)/kernel

# set some vars
KVERSION:=$(BT_KERNEL_RELEASE)
KIMAGE:=linux-$(KVERSION)

source:
	echo "already unpacked by linux source"


$(LINUX_BUILDDIR):
	mkdir -p $(LINUX_BUILDDIR)/usr/sbin


.build: $(LINUX_BUILDDIR) chklinuxdir
#	perl -i -p -e 's,^CROSS_COMPILE\s*=.*,CROSS_COMPILE =$(BT_STAGING_DIR)/usr/bin/,g' $(BT_LINUX_DIR)/Makefile
#	perl -i -p -e 's/CFLAGS\s*\:=\s*.*$$/CFLAGS \:= \$$\(CPPFLAGS\) -Wall -Wstrict-prototypes -Wno-trigraphs -Os \\/g' $(BT_LINUX_DIR)/Makefile
	mkdir -p $(BT_STAGING_DIR)/boot
	(for i in $(KARCHS); do export LOCALVERSION="-$$i" ; \
	cd $(BT_LINUX_DIR)-$$i && \
	make $(MAKEOPTS) $(KERN_IMAGE) && make $(MAKEOPTS) modules && \
	cp $(BT_LINUX_DIR)-$$i/arch/$(ARCH)/boot/$(KERN_IMAGE) $(LINUX_BUILDDIR)/$(KIMAGE)-$$i && \
	cp $(LINUX_BUILDDIR)/$(KIMAGE)-$$i $(BT_STAGING_DIR)/boot/linux-$$i && \
	cp $(BT_LINUX_DIR)-$$i/System.map $(LINUX_BUILDDIR)/System.map-$(KVERSION)-$$i && \
	make  ARCH=$(ARCH) INSTALL_MOD_PATH=$(LINUX_BUILDDIR) GENKSYMS="$(BT_STAGING_DIR)/sbin/genksyms" modules_install && \
	find $(LINUX_BUILDDIR)/lib/modules/$(KVERSION)-$$i -name '*.ko' | xargs gzip -9 -f && \
	depmod -ae -b $(LINUX_BUILDDIR) -F $(LINUX_BUILDDIR)/System.map-$(KVERSION)-$$i $(KVERSION)-$$i || exit 1; \
	done)
# Compile slabinfo tool
	$(TARGET_CC) $(CFLAGS) -o $(LINUX_BUILDDIR)/usr/sbin/slabinfo $(BT_LINUX_DIR)/tools/slub/slabinfo.c
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(LINUX_BUILDDIR)/usr/sbin/*
	cp -R $(LINUX_BUILDDIR)/lib $(LINUX_BUILDDIR)/usr $(BT_STAGING_DIR)
	#
	-rm -f package.cfg
	( for i in $(KARCHS); do \
	    echo $(ESCKEY) "?include <common.$$i>" >>package.cfg; \
	    sed 's,##KARCH##,'"$$i"',g' common.tpl >common.$$i ; \
	done )
	touch .build

build: .build

chklinuxdir:
ifeq ($(strip $(BT_LINUX_DIR)),)
	$(error "$$BT_LINUX_DIR is not set")
endif
ifeq ($(strip $(BT_BUILDROOT)),)
	$(error "$$BT_BUILDROOT is not set")
endif

clean: chklinuxdir
	(for i in $(KARCHS); do cd $(BT_LINUX_DIR)-$$i && make clean; done)
	rm -rf $(LINUX_BUILDDIR)
	-rm .build

srcclean:
