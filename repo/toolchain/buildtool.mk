# makefile for toolchain
include $(MASTERMAKEFILE)

GCC_DIR=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(GCC_SOURCE) 2>/dev/null )
UCLIBC_DIR=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(UCLIBC_SOURCE) 2>/dev/null )
BINUTILS_DIR=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(BINUTILS_SOURCE) 2>/dev/null )
DEPMOD_DIR=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(DEPMOD_SOURCE) 2>/dev/null )

BUILD_DIR=$(BT_BUILD_DIR)/toolchain
GCC_STAGE1_BUILD_DIR=$(BUILD_DIR)/gcc-stage1
GCC_STAGE2_BUILD_DIR=$(BUILD_DIR)/gcc-stage2
BINUTILS_BUILD_DIR=$(BUILD_DIR)/binutils
BINUTILS_BUILD_DIR2=$(BUILD_DIR)/binutils-target

export TARGET_DIR=$(BT_TOOLCHAIN_DIR)
export PREFIX=$(BT_TOOLCHAIN_DIR)

GCC_CONFOPTS=   --with-gnu-ld --with-gnu-as \
		--disable-libmudflap --disable-libssp \
		--disable-libquadmath --disable-libgomp

#save flags for cross-compiling target libs, and clean flags for toolchain
BT_CFLAGS=$(CFLAGS)
BT_LDFLAGS=$(LDFLAGS)
unexport CFLAGS
unexport CPPFLAGS
unexport LDFLAGS

$(UCLIBC_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(UCLIBC_SOURCE)
	# create config.$(GNU_TARGET_NAME)_headers with no CROSS_COMPILER_PREFIX
	perl -p -e 's,^CROSS_COMPILER_PREFIX=.*$$,CROSS_COMPILER_PREFIX="",' config.$(GNU_TARGET_NAME) > config.$(GNU_TARGET_NAME)_headers
#	cat $(UC_PATCH1) | patch -p1 -d $(UCLIBC_DIR)
#	cat $(UC_PATCH2) | patch -p1 -d $(UCLIBC_DIR)
#	cat $(UC_PATCH3) | patch -p1 -d $(UCLIBC_DIR)
#	cat $(UC_PATCH4) | patch -p1 -d $(UCLIBC_DIR)

	touch $(UCLIBC_DIR)/.source

$(BINUTILS_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(BINUTILS_SOURCE)
	touch $(BINUTILS_DIR)/.source

$(GCC_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(GCC_SOURCE)
	touch $(GCC_DIR)/.source

$(DEPMOD_DIR)/.source:
	$(BT_SETUP_BUILDDIR) -v $(DEPMOD_SOURCE)
	touch $(DEPMOD_DIR)/.source

source: $(UCLIBC_DIR)/.source $(GCC_DIR)/.source $(BINUTILS_DIR)/.source $(DEPMOD_DIR)/.source

###############################

$(UCLIBC_DIR)/.headers: $(UCLIBC_DIR)/.source
	cp -aL config.$(GNU_TARGET_NAME)_headers $(UCLIBC_DIR)/.config
	make $(MAKEOPTS) -C $(UCLIBC_DIR) install_headers KERNEL_HEADERS=$(TARGET_DIR)/usr/include
	touch $(UCLIBC_DIR)/.headers

$(BINUTILS_BUILD_DIR)/.build: $(BINUTILS_DIR)/.source $(UCLIBC_DIR)/.headers
	mkdir -p $(BINUTILS_BUILD_DIR)
	(cd $(BINUTILS_BUILD_DIR) && \
	 $(BINUTILS_DIR)/configure --target=$(GNU_TARGET_NAME) --prefix=$(BT_TOOLCHAIN_DIR) \
	  --includedir=$(BT_TOOLCHAIN_DIR)/usr/include  --with-sysroot=$(BT_TOOLCHAIN_DIR) \
	  --with-build-sysroot=$(BT_TOOLCHAIN_DIR) && \
	 make $(MAKEOPTS) KERNEL_HEADERS=$(TARGET_DIR)/usr/include &&  make install) || exit 1
	touch $(BINUTILS_BUILD_DIR)/.build

$(GCC_STAGE1_BUILD_DIR)/.build: $(GCC_DIR)/.source $(BINUTILS_BUILD_DIR)/.build
	mkdir -p $(GCC_STAGE1_BUILD_DIR)
	(cd $(GCC_STAGE1_BUILD_DIR) && \
	 $(GCC_DIR)/configure --target=$(GNU_TARGET_NAME) --with-sysroot=$(BT_TOOLCHAIN_DIR) \
	  --includedir=$(BT_TOOLCHAIN_DIR)/usr/include --prefix=$(BT_TOOLCHAIN_DIR) \
	  --disable-shared --enable-ld=yes $(GCC_CONFOPTS) \
	  --enable-languages=c && \
	  make $(MAKEOPTS) && make install) || exit 1
	touch $(GCC_STAGE1_BUILD_DIR)/.build

$(GCC_STAGE2_BUILD_DIR)/.build: $(GCC_DIR)/.source $(GCC_STAGE1_BUILD_DIR)/.build
	mkdir -p $(GCC_STAGE2_BUILD_DIR)
	(cd $(GCC_STAGE2_BUILD_DIR) && \
	 $(GCC_DIR)/configure --target=$(GNU_TARGET_NAME) --with-sysroot=$(BT_TOOLCHAIN_DIR) \
	  --includedir=$(BT_TOOLCHAIN_DIR)/usr/include --prefix=$(BT_TOOLCHAIN_DIR) \
	  --enable-shared $(GCC_CONFOPTS) \
	  --enable-languages=c++ && \
	  make $(MAKEOPTS) all-host all-target-libgcc all-target-libstdc++-v3 && \
	  make install-host install-target-libgcc install-target-libstdc++-v3) || exit 1
	touch $(GCC_STAGE2_BUILD_DIR)/.build

$(UCLIBC_DIR)/.build: $(UCLIBC_DIR)/.source $(GCC_STAGE1_BUILD_DIR)/.build
	cp -aL config.$(GNU_TARGET_NAME) $(UCLIBC_DIR)/.config
	# force full path to KERNEL_HEADERS into uClibc .config
	# since command-line override doesn't always work
	perl -i -p -e "s,^KERNEL_HEADERS=.*,KERNEL_HEADERS=\"$(TARGET_DIR)/usr/include\"," $(UCLIBC_DIR)/.config
	(cd $(UCLIBC_DIR) && make oldconfig && make all utils && make install)
	mkdir -p $(BT_STAGING_DIR)/usr/bin
	cp -a $(UCLIBC_DIR)/utils/ldd $(BT_STAGING_DIR)/usr/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BT_STAGING_DIR)/usr/bin/ldd
	touch $(UCLIBC_DIR)/.build

#binutils + libs for target host
$(BINUTILS_BUILD_DIR2)/.build: $(BINUTILS_DIR)/.source $(UCLIBC_DIR)/.build $(GCC_STAGE2_BUILD_DIR)/.build
	mkdir -p $(BINUTILS_BUILD_DIR2)
	(cd $(BINUTILS_BUILD_DIR2) && CFLAGS="$(BT_CFLAGS)" LDFLAGS="$(BT_LDFLAGS)" \
	 $(BINUTILS_DIR)/configure --host=$(GNU_TARGET_NAME) --prefix=/usr \
	  --build=$(GNU_BUILD_NAME) \
	  --with-build-sysroot=$(BT_STAGING_DIR) && \
	 make $(MAKEOPTS) KERNEL_HEADERS=$(TARGET_DIR)/usr/include configure-host && \
	 make $(MAKEOPTS) KERNEL_HEADERS=$(TARGET_DIR)/usr/include DESTDIR=$(BINUTILS_BUILD_DIR2)-built \
	 install-libiberty install-intl install-bfd install-binutils install-opcodes) || exit 1
	 perl -i -p -e "s,^libdir=.*$$,libdir='$(BT_STAGING_DIR)/usr/lib\'," $(BINUTILS_BUILD_DIR2)-built/usr/lib/*.la
	touch $(BINUTILS_BUILD_DIR2)/.build

#depmod
$(DEPMOD_DIR)/Makefile: $(DEPMOD_DIR)/.source
	(cd $(DEPMOD_DIR); ./configure --enable-zlib --enable-zlib-dynamic --disable-static-utils)

$(DEPMOD_DIR)/.build: $(DEPMOD_DIR)/Makefile
	mkdir -p $(BT_TOOLCHAIN_DIR)/bin
	make $(MAKEOPTS) -C $(DEPMOD_DIR) depmod
	cp -a $(DEPMOD_DIR)/build/depmod $(BT_TOOLCHAIN_DIR)/bin
	touch $@

build: $(BINUTILS_BUILD_DIR)/.build $(UCLIBC_DIR)/.build $(GCC_STAGE1_BUILD_DIR)/.build $(GCC_STAGE2_BUILD_DIR)/.build $(BINUTILS_BUILD_DIR2)/.build $(DEPMOD_DIR)/.build
	mkdir -p $(BT_STAGING_DIR)/lib
	cp -a $(BT_TOOLCHAIN_DIR)/lib/*.so.* $(BT_STAGING_DIR)/lib
	cp -a $(BT_TOOLCHAIN_DIR)/lib/*.so $(BT_STAGING_DIR)/lib
	cp -a $(BT_TOOLCHAIN_DIR)/$(GNU_TARGET_NAME)/lib/*.so.* $(BT_STAGING_DIR)/lib
	cp -a $(BT_TOOLCHAIN_DIR)/$(GNU_TARGET_NAME)/lib/*.so $(BT_STAGING_DIR)/lib
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BINUTILS_BUILD_DIR2)-built/usr/bin/*
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BINUTILS_BUILD_DIR2)-built/usr/$(GNU_TARGET_NAME)/*
	-rm -rf $(BINUTILS_BUILD_DIR2)-built/usr/share
	cp -a $(BINUTILS_BUILD_DIR2)-built/* $(BT_STAGING_DIR)/
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(BT_STAGING_DIR)/lib/*

###############################

clean:
	-rm -rf $(BUILD_DIR)
	-make -C $(UCLIBC_DIR) clean
	-rm -f $(UCLIBC_DIR)/.build


srcclean: clean
	-rm -rf $(BINUTILS_DIR)
	-rm -rf $(GCC_DIR)
	-rm -rf $(UCIBC_DIR)
