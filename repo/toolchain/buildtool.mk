# makefile for elvis-tiny
include $(MASTERMAKEFILE)

CUR_DIR=$(shell pwd)
GCC_DIR=$(CUR_DIR)/gcc-4.6.2
UCLIBC_DIR=$(CUR_DIR)/uClibc-0.9.32
BINUTILS_DIR=$(CUR_DIR)/binutils-2.21.1

BUILD_DIR=$(BT_BUILD_DIR)/toolchain
GCC_STAGE1_BUILD_DIR=$(BUILD_DIR)/gcc-stage1
GCC_STAGE2_BUILD_DIR=$(BUILD_DIR)/gcc-stage2
BINUTILS_BUILD_DIR=$(BUILD_DIR)/binutils

export TARGET_DIR=$(TOOLCHAIN_DIR)
export PREFIX=$(TOOLCHAIN_DIR)

GCC_CONFOPTS=   --with-gnu-ld --with-gnu-as \
		--disable-libmudflap --disable-libssp \
		--disable-libquadmath --disable-libgomp


$(UCLIBC_DIR)/.source:
	bzcat $(UC_TARFILE) | tar xvf -
	patch $(UC_CONFIG) $(UC_CONFIG_PATCH) -o $(UC_CONFIG)_headers
	cat $(UC_PATCH1) | patch -p1 -d $(UCLIBC_DIR)
	touch $(UCLIBC_DIR)/.source

$(BINUTILS_DIR)/.source:
	bzcat $(BINUTILS_TARFILE) | tar -xvf -
	touch $(BINUTILS_DIR)/.source

$(GCC_DIR)/.source:
	bzcat $(GCCTAR) | tar -xvf -
	touch $(GCC_DIR)/.source

source: $(UCLIBC_DIR)/.source $(GCC_DIR)/.source $(BINUTILS_DIR)/.source

###############################

$(UCLIBC_DIR)/.headers: $(UCLIBC_DIR)/.source
	cp -aL $(UC_CONFIG)_headers $(UCLIBC_DIR)/.config
	make -C $(UCLIBC_DIR) install_headers KERNEL_HEADERS=$(TARGET_DIR)/usr/include
	touch $(UCLIBC_DIR)/.headers

$(BINUTILS_BUILD_DIR)/.build: $(BINUTILS_DIR)/.source $(UCLIBC_DIR)/.headers
	mkdir -p $(BINUTILS_BUILD_DIR)
	(cd $(BINUTILS_BUILD_DIR) && \
	 $(BINUTILS_DIR)/configure --target=$(GNU_TARGET_NAME) --prefix=$(TOOLCHAIN_DIR) \
	  --includedir=$(TOOLCHAIN_DIR)/usr/include  --with-sysroot=$(TOOLCHAIN_DIR) \
	  --with-build-sysroot=$(TOOLCHAIN_DIR) && \
	 make $(MAKEOPTS) KERNEL_HEADERS=$TARGET_DIR/include &&  make install) || exit 1
	touch $(BINUTILS_BUILD_DIR)/.build

$(GCC_STAGE1_BUILD_DIR)/.build: $(GCC_DIR)/.source
	mkdir -p $(GCC_STAGE1_BUILD_DIR)
	(cd $(GCC_STAGE1_BUILD_DIR) && \
	 $(GCC_DIR)/configure --target=$(GNU_TARGET_NAME) --with-sysroot=$(TOOLCHAIN_DIR) \
	  --includedir=$(TOOLCHAIN_DIR)/usr/include --prefix=$(TOOLCHAIN_DIR) \
	  --disable-shared --enable-ld=yes $(GCC_CONFOPTS) \
	  --enable-languages=c && \
	  make $(MAKEOPTS) && make install) || exit 1
	touch $(GCC_STAGE1_BUILD_DIR)/.build

$(GCC_STAGE2_BUILD_DIR)/.build: $(GCC_DIR)/.source $(GCC_STAGE1_BUILD_DIR)/.build
	mkdir -p $(GCC_STAGE2_BUILD_DIR)
	(cd $(GCC_STAGE2_BUILD_DIR) && \
	 $(GCC_DIR)/configure --target=$(GNU_TARGET_NAME) --with-sysroot=$(TOOLCHAIN_DIR) \
	  --includedir=$(TOOLCHAIN_DIR)/usr/include --prefix=$(TOOLCHAIN_DIR) \
	  --enable-shared $(GCC_CONFOPTS) \
	  --enable-languages=c++ && \
	  make $(MAKEOPTS) all-host all-target-libgcc && make install-host install-target-libgcc) || exit 1
	touch $(GCC_STAGE2_BUILD_DIR)/.build

$(UCLIBC_DIR)/.build: $(UCLIBC_DIR)/.source $(GCC_STAGE1_BUILD_DIR)/.build
	cp -aL $(UC_CONFIG) $(UCLIBC_DIR)/.config
	(cd $(UCLIBC_DIR) && make oldconfig && make $(MAKEOPTS) && \
	 make install)
	touch $(UCLIBC_DIR)/.build

build: $(BINUTILS_BUILD_DIR)/.build $(UCLIBC_DIR)/.build $(GCC_STAGE1_BUILD_DIR)/.build $(GCC_STAGE2_BUILD_DIR)/.build
	mkdir -p $(BT_STAGING_DIR)/lib
	cp -a $(TOOLCHAIN_DIR)/lib/*.so.* $(BT_STAGING_DIR)/lib
	cp -a $(TOOLCHAIN_DIR)/lib/*.so $(BT_STAGING_DIR)/lib
	cp -a $(TOOLCHAIN_DIR)/$(GNU_TARGET_NAME)/lib/libgcc_s* $(BT_STAGING_DIR)/lib
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
