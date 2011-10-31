# buildtool make file for buildenv
# $Id: buildtool.mk,v 1.17 2011/01/22 15:20:18 kapeka Exp $
# 
# Note that this is some kind of a hack as you normally should do things 
# not the way they are handled here 

include $(MASTERMAKEFILE)

LINVER=$(shell echo $(KERNEL_SOURCE) | sed 's/\.\(tar\.\|\t\)\(gz\|bz2\)//;s/^.*\-//')

.source:
	bzcat $(KERNEL_SOURCE) | tar -xvf -
	ln -s linux-$(LINVER) linux
	cat $(KERNEL_PATCH1) | patch -d linux-$(LINVER)/lib -p0
	cat $(KERNEL_PATCH2) | patch -d linux-$(LINVER) -p1
	zcat $(KERNEL_PATCH3) | patch -d linux-$(LINVER) -p1
	cat $(KERNEL_PATCH4) | patch -d linux-$(LINVER) -p1
	mkdir -p $(TOOLCHAIN_DIR)/usr
	touch .source


.configured: .source
	(for i in $(KARCHS); do \
	patch -i $(LINUX_CONFIG)-$$i.patch -o $(LINUX_CONFIG)-$$i $(LINUX_CONFIG) && \
	mkdir -p linux-$$i && cp $(LINUX_CONFIG)-$$i linux-$$i/.config && \
	ARCH=$(ARCH) $(MAKE) -C linux-$(LINVER) O=../linux-$$i oldconfig || \
	exit 1; done ; \
	ARCH=$(ARCH) $(MAKE) -C linux-$$i include/linux/version.h headers_install && \
	cp -r linux-$$i/usr/include $(TOOLCHAIN_DIR)/usr)
	touch .configured

source: .source .configured

build: 	.configured
	echo "nothing done here right now, all done by buildenv and kernel package"

clean:
	-rm .configured
	for i in $(KARCHS); do rm -rf linux-$$i; done

srcclean: 	
	for i in $(KARCHS); do rm -rf linux-$$i; done
	rm -f linux
	rm -rf linux-$(LINVER)
	-rm .configured
	-rm .source

