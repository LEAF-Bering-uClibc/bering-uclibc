# $Id: buildtool.mk,v 1.19 2011/01/03 18:27:10 nitr0man Exp $
# changed for working with uclibc-bering buildtool by Arne Bernin <arne@alamut.de>
#
#
# Copyright (C) 2002-2003 Erik Andersen <andersen@uclibc.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

include $(MASTERMAKEFILE)


#############################################################
#
# You should probably leave this stuff alone unless you are
# hacking on the toolchain...
#
#############################################################

TARGET_LANGUAGES:=c,c++

# If you want multilib enabled, enable this...
MULTILIB:=--enable-multilib

GCC_VERSION:=4.4.5
GMP_VERSION:=4.3.2
MPFR_VERSION:=2.3.2
MPC_VERSION:=0.8.2
UCLIBC_VERSION:=0.9.30.3
BINUTILS_VERSION:=2.21

###########################################################
# override path (FIXME: just delete the staging_dir path)
export PATH:=/bin:/usr/bin:/usr/local/bin

STAGING_DIR:=$(BT_STAGING_DIR)

LINUX_DIR:=$(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)

TOOL_BUILD_DIR:=$(BT_SOURCE_DIR)/buildenv

TARGET_PATH=$(STAGING_DIR)/bin:/bin:/sbin:/usr/bin:/usr/sbin
TARGET_CROSS=$(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-
TARGET_CC=$(TARGET_CROSS)gcc
CFLAGS=$(BT_COPT_FLAGS)


#############################################################
#
# Where we can find things....
#
# for various dependancy reasons, these need to live
# here at the top...  Easier to find things here anyways...
#
#############################################################
#BINUTILS_SITE:=ftp://ftp.gnu.org/gnu/binutils/
BINUTILS_SOURCE:=$(BINUTILS_TARFILE)
BINUTILS_DIR:=$(TOOL_BUILD_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_BUILD_DIR=$(BT_BUILD_DIR)/binutils-initial
BINUTILS_BUILD_FINAL_DIR=$(BT_BUILD_DIR)/binutils-final

UCLIBC_DIR:=$(TOOL_BUILD_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_SOURCE:=$(UC_TARFILE)
#UCLIBC_SITE:=http://www.uclibc.org/downloads

#GCC_SITE:=ftp://ftp.gnu.org/gnu/gcc/
GCC_SOURCE:=$(GCCTAR)
GCC_DIR:=$(TOOL_BUILD_DIR)/gcc-$(GCC_VERSION)

GMP_SOURCE:=$(GMP_TARFILE)
GMP_DIR:=$(GCC_DIR)/gmp
GMP_BUILD_DIR:=$(TOOL_BUILD_DIR)/gmp-$(GMP_VERSION)-build
GMP_TARGET_DIR:=$(BT_BUILD_DIR)/gmp

MPFR_SOURCE:=$(MPFR_TARFILE)
MPFR_DIR:=$(GCC_DIR)/mpfr

MPC_SOURCE:=$(MPC_TARFILE)
MPC_DIR:=$(GCC_DIR)/mpc

#############################################################
#
# Setup some initial paths
#
#############################################################
.setup:
	mkdir -p $(TOOL_BUILD_DIR)
	mkdir -p $(STAGING_DIR)
	mkdir -p $(STAGING_DIR)/include
	mkdir -p $(STAGING_DIR)/lib/gcc-lib
	mkdir -p $(STAGING_DIR)/usr/lib
	mkdir -p $(STAGING_DIR)/usr/bin
	mkdir -p $(STAGING_DIR)/usr/include
	mkdir -p $(STAGING_DIR)/$(GNU_TARGET_NAME)/
	(cd $(STAGING_DIR)/$(GNU_TARGET_NAME); ln -fs ../lib)
	(cd $(STAGING_DIR)/$(GNU_TARGET_NAME); ln -fs ../include)
#	(cd $(STAGING_DIR)/$(GNU_TARGET_NAME); ln -fs ../include sys-include)
	(cd $(STAGING_DIR)/usr/lib; ln -fs ../../lib/gcc-lib)
	touch $(STAGING_DIR)/.setup


#############################################################
#
# Setup some initial stuff
#
#############################################################
uclibc_toolchain: gcc_final

uclibc_toolchain-source: $(DL_DIR)/$(BINUTILS_SOURCE) $(DL_DIR)/$(UCLIBC_SOURCE) $(DL_DIR)/$(GCC_SOURCE)

uclibc_toolchain-clean: gcc_final-clean uclibc-clean gcc_initial-clean binutils-clean

uclibc_toolchain-dirclean: gcc_final-dirclean uclibc-dirclean gcc_initial-dirclean binutils-dirclean



#############################################################
#
# build binutils
#
#############################################################
BINUTILS_DIR1:=$(TOOL_BUILD_DIR)/binutils-$(BINUTILS_VERSION)-initial
BINUTILS_DIR2:=$(TOOL_BUILD_DIR)/binutils-$(BINUTILS_VERSION)-final

$(BINUTILS_DIR)/.unpacked:
	bzcat $(BINUTILS_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
	touch $(BINUTILS_DIR)/.unpacked

$(BINUTILS_DIR)/.patched: $(BINUTILS_DIR)/.unpacked
	# Apply any files named binutils-*.patch from the source directory to binutils
##	$(SOURCE_DIR)/patch-kernel.sh $(BINUTILS_DIR) $(SOURCE_DIR) binutils-*.patch
	#
	# Enable combreloc, since it is such a nice thing to have...
	#
	-perl -i -p -e "s,link_info.combreloc = false,link_info.combreloc = true,g;" \
	$(BINUTILS_DIR)/ld/ldmain.c
	#
	# Hack binutils to use the correct shared lib loader
	#
	(cd $(BINUTILS_DIR); perl -i -p -e "s,#.*define.*ELF_DYNAMIC_INTERPRETER.*\".*\"\
	,#define ELF_DYNAMIC_INTERPRETER \"/lib/ld-uClibc.so.0\",;" \
	`grep -lr "#.*define.*ELF_DYNAMIC_INTERPRETER.*\".*\"" $(BINUTILS_DIR)`);
	(cd $(BINUTILS_DIR); perl -i -p -e "s,/lib/ld-linux.so[\.0-9]*,\
	/lib/ld-uClibc.so.0,;" \
	`grep -lr "#.*define.*ELF_DYNAMIC_INTERPRETER.*\".*\"" $(BINUTILS_DIR)`);
	#
	# Hack binutils to prevent it from searching the host system
	# for libraries.  We only want libraries for the target system. 
	#        
	(cd $(BINUTILS_DIR); perl -i -p -e "s,^NATIVE_LIB_DIRS.*,\
	NATIVE_LIB_DIRS='$(STAGING_DIR)/usr/lib $(STAGING_DIR)/lib',;" \
	$(BINUTILS_DIR)/ld/configure.tgt);
	#
	# Hack binutils to prevent error "declaration of 'clone' shadows a global declaration"
	#
	(cd $(BINUTILS_DIR); perl -i -p -e "s/clone/b_clone/g" ./gas/config/obj-elf.c)
	(cd $(BINUTILS_DIR); perl -i -p -e "s/symbol_b_clone/symbol_clone/" ./gas/config/obj-elf.c)
	#
	touch $(BINUTILS_DIR)/.patched

$(BINUTILS_DIR1)/.configured: $(BINUTILS_DIR)/.patched
	mkdir -p $(BINUTILS_DIR1)
	(cd $(BINUTILS_DIR1); CC=$(HOSTCC) \
		$(BINUTILS_DIR)/configure \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/ \
		--enable-targets=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		$(MULTILIB) \
		--program-prefix=$(GNU_TARGET_NAME)-);
	touch $(BINUTILS_DIR1)/.configured


$(BINUTILS_DIR1)/binutils/objdump: $(BINUTILS_DIR1)/.configured
	$(MAKE) $(MAKEOPTS) -C $(BINUTILS_DIR1) \
		all-binutils all-gas all-gprof all-ld

$(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR1)/binutils/objdump 
	mkdir -p $(BINUTILS_BUILD_DIR)/$(GNU_TARGET_NAME)
	mkdir -p $(BINUTILS_BUILD_DIR)/lib
	(cd $(BINUTILS_BUILD_DIR)/$(GNU_TARGET_NAME); test -e lib || ln -s ../lib lib)
	$(MAKE) $(MAKEOPTS) DESTDIR=$(BINUTILS_BUILD_DIR) -C $(BINUTILS_DIR1) \
		install-binutils install-gas \
		install-gprof install-ld
	rm -rf $(BINUTILS_BUILD_DIR)/share/info $(BINUTILS_BUILD_DIR)/share/man \
		$(BINUTILS_BUILD_DIR)/share/doc $(BINUTILS_BUILD_DIR)/share/locale \
		$(BINUTILS_BUILD_DIR)/lib/*.a $(BINUTILS_BUILD_DIR)/lib/*.la
	mkdir -p $(BINUTILS_BUILD_DIR)/usr/bin;
	set -e; \
	for app in addr2line ar as c++filt gprof ld nm objcopy \
		    objdump ranlib readelf size strings strip ; \
	do \
		if [ -x $(BINUTILS_BUILD_DIR)/bin/$(GNU_TARGET_NAME)-$${app} ] ; then \
		    (cd $(BINUTILS_BUILD_DIR)/$(GNU_TARGET_NAME)/bin; \
			ln -fs ../../bin/$(GNU_TARGET_NAME)-$${app} $${app}; \
		    ); \
		    (cd $(BINUTILS_BUILD_DIR)/usr/bin; \
			ln -fs ../../bin/$(GNU_TARGET_NAME)-$${app} $${app}; \
		    ); \
		fi; \
	done;
	cp -a $(BINUTILS_BUILD_DIR)/* $(STAGING_DIR)

#	rm -rf $(STAGING_DIR)/info $(STAGING_DIR)/man \
#		$(STAGING_DIR)/share/doc $(STAGING_DIR)/share/locale
#	set -e; \
#	for app in addr2line ar as c++filt gprof ld nm objcopy \
#		    objdump ranlib readelf size strings strip ; \
#	do \
#		if [ -x $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-$${app} ] ; then \
#		    (cd $(STAGING_DIR)/$(GNU_TARGET_NAME)/bin; \
#			ln -fs ../../bin/$(GNU_TARGET_NAME)-$${app} $${app}; \
#		    ); \
#		    (cd $(STAGING_DIR)/usr/bin; \
#			ln -fs ../../bin/$(GNU_TARGET_NAME)-$${app} $${app}; \
#		    ); \
#		fi; \
#	done;

$(BINUTILS_DIR2)/.configured: $(BINUTILS_DIR)/.patched $(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/ld \
	 $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-gcc
	mkdir -p $(BINUTILS_DIR2)
	(cd $(BINUTILS_DIR2); CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" \
		$(BINUTILS_DIR)/configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/ \
		--includedir=/include \
		--libdir=/lib \
		--enable-targets=$(GNU_TARGET_NAME) \
		--enable-shared \
		$(MULTILIB) \
		--program-prefix=$(GNU_TARGET_NAME)-);
#		--exec-prefix=/ \
#		--bindir=/bin \
#		--sbindir=$(STAGING_DIR)/sbin \
#		--sysconfdir=$(STAGING_DIR)/etc \
#		--datadir=$(STAGING_DIR)/share \
#		--includedir=$(STAGING_DIR)/include \
#		--libdir=$(STAGING_DIR)/lib \
#		--localstatedir=$(STAGING_DIR)/var \
#		--mandir=$(STAGING_DIR)/man \
#		--infodir=$(STAGING_DIR)/info \
	touch $(BINUTILS_DIR2)/.configured

$(BINUTILS_DIR2)/bfd/.libs/libbfd.a: $(BINUTILS_DIR2)/.configured
	$(MAKE) $(MAKEOPTS) -C $(BINUTILS_DIR2) all

$(STAGING_DIR)/lib/libbfd.a: $(BINUTILS_DIR2)/bfd/.libs/libbfd.a 
	mkdir -p $(BINUTILS_BUILD_FINAL_DIR)/$(GNU_TARGET_NAME)
	(cd $(BINUTILS_BUILD_FINAL_DIR)/$(GNU_TARGET_NAME); test -e lib || ln -s ../lib lib)
	mkdir -p $(BINUTILS_BUILD_FINAL_DIR)/lib
	mkdir -p $(BINUTILS_BUILD_FINAL_DIR)/include
	$(MAKE) $(MAKEOPTS) DESTDIR=$(BINUTILS_BUILD_FINAL_DIR) -C $(BINUTILS_DIR2) \
		install
	-strip $(BT_STRIP_LIBOPTS) $(BINUTILS_BUILD_FINAL_DIR)/bin/*
	-strip $(BT_STRIP_LIBOPTS) $(BINUTILS_BUILD_FINAL_DIR)/lib/*
	rm -rf $(BINUTILS_BUILD_FINAL_DIR)/share/info $(BINUTILS_BUILD_FINAL_DIR)/share/man \
		$(BINUTILS_BUILD_FINAL_DIR)/share/doc $(BINUTILS_BUILD_FINAL_DIR)/share/locale
	cp -a $(BINUTILS_BUILD_FINAL_DIR)/* $(STAGING_DIR)

$(STAGING_DIR)/lib/libg.a:
	$(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/ar rv $(STAGING_DIR)/lib/libg.a;

binutils: $(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/ld $(STAGING_DIR)/lib/libg.a 

binutils-clean:
	rm -f $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)*
	-$(MAKE) -C $(BINUTILS_DIR2) clean
	-$(MAKE) -C $(BINUTILS_DIR1) clean

binutils-dirclean:
	rm -rf $(BINUTILS_DIR2)
	rm -rf $(BINUTILS_DIR1)




#############################################################
#
# Next build first pass gcc compiler
#
#############################################################
GCC_BUILD_DIR1:=$(TOOL_BUILD_DIR)/gcc-$(GCC_VERSION)-initial

$(GCC_DIR)/.unpacked:
	bzcat $(GCC_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
	touch $(GCC_DIR)/.unpacked

$(GCC_DIR)/.patched: $(GCC_DIR)/.unpacked
	# Apply any files named gcc-*.patch from the source directory to gcc
	cat $(GCC_PATCH1) | patch -p0 -d $(GCC_DIR)
##	$(SOURCE_DIR)/patch-kernel.sh $(GCC_DIR) $(SOURCE_DIR) gcc-*.patch
#	(cd $(GCC_DIR) ; patch -p1 < ../gcc-3.3-libstdc++nowchar.patch)
#	(cd $(GCC_DIR) ; patch -p1 < ../gcc-obstack.h.patch)
#	(cd $(GCC_DIR) ; patch -p1 < ../gcc-open.patch)
	# fix configure for bash 3.0
#	perl -i -p -e "s,trap 0,trap - 0,g" $(GCC_DIR)/configure
	touch $(GCC_DIR)/.patched

$(GCC_DIR)/.gcc_build_hacks: $(GCC_DIR)/.patched
	#
	# Hack things to use the correct shared lib loader
	#
#	(cd $(GCC_DIR); set -e; export LIST="`grep -lr -- "-dynamic-linker.*\.so[\.0-9]*" *`";\
#		if [ -n "$$LIST" ] ; then \
#		perl -i -p -e "s,-dynamic-linker.*\.so[\.0-9]*},\
#		    -dynamic-linker /lib/ld-uClibc.so.0},;" $$LIST; fi);
	(cd $(GCC_DIR); set -e; export LIST="`grep -lr -- "GLIBC_DYNAMIC_LINKER.*\.so[\.0-9]*" *`";\
		if [ -n "$$LIST" ] ; then \
		perl -i -p -e "s,GLIBC_DYNAMIC_LINKER.*\".*\.so[\.0-9]*\",\
	GLIBC_DYNAMIC_LINKER \"/lib/ld-uClibc.so.0\",;" $$LIST; fi);
	#
	# Prevent system glibc start files from leaking in uninvited...
	#
#	perl -i -p -e "s,standard_startfile_prefix_1 = \".*,standard_startfile_prefix_1 =\
#		\"$(STAGING_DIR)/lib/\";,;" $(GCC_DIR)/gcc/gcc.c;
#	perl -i -p -e "s,standard_startfile_prefix_2 = \".*,standard_startfile_prefix_2 =\
#		\"$(STAGING_DIR)/usr/lib/\";,;" $(GCC_DIR)/gcc/gcc.c;
	perl -i -p -e "s,(STANDARD_STARTFILE_PREFIX_[12]) \"(/usr)?(/lib/\"),\1 \"$(STAGING_DIR)\2\3,;" \
	$(GCC_DIR)/gcc/gcc.c;
#	perl -i -p -e "s,STANDARD_STARTFILE_PREFIX_1 = \".*,STANDARD_STARTFILE_PREFIX_1 = \
#	$(GCC_DIR)/gcc/gcc.c;
#	perl -i -p -e "s,STANDARD_STARTFILE_PREFIX_2 = \".*,STANDARD_STARTFILE_PREFIX_2 = \
#	\"$(STAGING_DIR)/usr/lib/\";,;" $(GCC_DIR)/gcc/gcc.c;
	perl -i -p -e "s,standard_exec_prefix_1 = \".*,standard_exec_prefix_1 = \
	\"$(STAGING_DIR)/usr/libexec/gcc/\";,;" $(GCC_DIR)/gcc/gcc.c;
	perl -i -p -e "s,standard_exec_prefix_2 = \".*,standard_exec_prefix_2 = \
	\"$(STAGING_DIR)/usr/lib/gcc/\";,;" $(GCC_DIR)/gcc/gcc.c;
	#
	# Prevent system glibc include files from leaking in uninvited...
	#
	perl -i -p -e "s,^NATIVE_SYSTEM_HEADER_DIR.*,NATIVE_SYSTEM_HEADER_DIR= \
	$(STAGING_DIR)/include,;" $(GCC_DIR)/gcc/Makefile.in;
	perl -i -p -e "s,^CROSS_SYSTEM_HEADER_DIR.*,CROSS_SYSTEM_HEADER_DIR= \
	$(STAGING_DIR)/include,;" $(GCC_DIR)/gcc/Makefile.in;
	perl -i -p -e "s,^#define.*STANDARD_INCLUDE_DIR.*,#define STANDARD_INCLUDE_DIR \
	\"$(STAGING_DIR)/include\",;" $(GCC_DIR)/gcc/cppdefault.c;
	#
	# Prevent system glibc libraries from being found by collect2
	# when it calls locatelib() and rummages about the system looking
	# for libraries with the correct name...
	#            
	perl -i -p -e "s,\"/lib,\"$(STAGING_DIR)/lib,g;" $(GCC_DIR)/gcc/collect2.c
	perl -i -p -e "s,\"/usr/,\"$(STAGING_DIR)/usr/,g;" $(GCC_DIR)/gcc/collect2.c
	#
	# Prevent gcc from using the unwind-dw2-fde-glibc code
	#
	perl -i -p -e "s,^#ifndef inhibit_libc,#define inhibit_libc\n\
	#ifndef inhibit_libc,g;" $(GCC_DIR)/gcc/unwind-dw2-fde-glibc.c;
	touch $(GCC_DIR)/.gcc_build_hacks
	
# The --without-headers option stopped working with gcc 3.0 and has never been
# fixed, so we need to actually have working C library header files prior to
# the step or libgcc will not build...
$(GCC_BUILD_DIR1)/.configured: $(GCC_DIR)/.gcc_build_hacks
	mkdir -p $(GCC_BUILD_DIR1)
	(cd $(GCC_BUILD_DIR1); PATH=$(TARGET_PATH) \
		AR=$(TARGET_CROSS)ar \
		RANLIB=$(TARGET_CROSS)ranlib \
		CC="$(HOSTCC)" \
		$(GCC_DIR)/configure \
		--prefix=$(STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--exec-prefix=$(STAGING_DIR) \
		--bindir=$(STAGING_DIR)/bin \
		--sbindir=$(STAGING_DIR)/sbin \
		--sysconfdir=$(STAGING_DIR)/etc \
		--datadir=$(STAGING_DIR)/share \
		--includedir=$(STAGING_DIR)/include \
		--libdir=$(STAGING_DIR)/lib \
		--localstatedir=$(STAGING_DIR)/var \
		--mandir=$(STAGING_DIR)/man \
		--infodir=$(STAGING_DIR)/info \
		--with-local-prefix=$(STAGING_DIR)/usr/local \
		--oldincludedir=$(STAGING_DIR)/include \
		--enable-languages=c \
		--disable-shared \
		--disable-__cxa_atexit \
		--enable-target-optspace \
		--with-gnu-ld \
		--disable-nls \
		$(MULTILIB) \
		$(EXTRA_GCC_CONFIG_OPTIONS));
	touch $(GCC_BUILD_DIR1)/.configured

$(GCC_BUILD_DIR1)/.compiled: $(GCC_BUILD_DIR1)/.configured
	#ln -snf ../../source/linux/linux/include/linux $(STAGING_DIR)/include/linux
	#ln -snf ../../source/linux/linux/arch/x86/include/asm $(STAGING_DIR)/include/asm
	#ln -snf ../../source/linux/linux/include/asm-generic $(STAGING_DIR)/include/asm-generic
	cp -aL uname $(STAGING_DIR)/bin && chmod +x $(STAGING_DIR)/bin/uname
	cp -aL gcc-m32 $(STAGING_DIR)/bin && chmod +x $(STAGING_DIR)/bin/gcc-m32
	PATH=$(TARGET_PATH) $(MAKE) -C $(GCC_BUILD_DIR1) \
	AR_FOR_TARGET=$(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ar \
	RANLIB_FOR_TARGET=$(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ranlib all-gcc all-stage1-target-libgcc
	touch $(GCC_BUILD_DIR1)/.compiled

$(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-gcc: $(GCC_BUILD_DIR1)/.compiled
	PATH=$(TARGET_PATH) $(MAKE) $(MAKEOPTS) -C $(GCC_BUILD_DIR1) install-gcc install-target-libgcc
	#rm -f $(STAGING_DIR)/bin/gccbug $(STAGING_DIR)/bin/gcov
	#rm -rf $(STAGING_DIR)/info $(STAGING_DIR)/man $(STAGING_DIR)/share/doc $(STAGING_DIR)/share/locale

gcc_initial: uclibc-configured binutils $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-gcc

gcc_initial-clean:
	rm -rf $(GCC_BUILD_DIR1)

gcc_initial-dirclean:
	rm -rf $(GCC_BUILD_DIR1) $(GCC_DIR)



#############################################################
#
# uClibc is built in two stages.  First, we install the uClibc 
# include files so that gcc can be built.  Later when gcc for 
# the target arch has been compiled, we can actually compile 
# uClibc for the target... 
#
#############################################################
$(UCLIBC_DIR)/.unpacked: 
	bzcat $(UCLIBC_SOURCE) | tar -xvf -
	zcat $(UC_PATCH1) | patch -d $(UCLIBC_DIR) -p1 
	cat $(UC_PATCH2) | patch -d $(UCLIBC_DIR) -p1 
	# This next patch is temporary - see comments in buildtool.cfg
	cat $(UC_PATCH3) | patch -d $(UCLIBC_DIR) -p1
	touch $(UCLIBC_DIR)/.unpacked

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.unpacked
#	perl -i -p -e 's,^CROSS=.*,TARGET_ARCH=$(ARCH)\nCROSS=$(TARGET_CROSS),g' \
#		$(UCLIBC_DIR)/Rules.mak
	cp $(TOOL_BUILD_DIR)/$(UC_CONFIG) $(UCLIBC_DIR)/.config
	perl -i -p -e 's,^CROSS_COMPILER_PREFIX=.*,CROSS_COMPILER_PREFIX="$(TARGET_CROSS)",g' \
		$(UCLIBC_DIR)/.config
	perl -i -p -e 's,^.*TARGET_$(ARCH).*,TARGET_$(ARCH)=y,g' \
		$(UCLIBC_DIR)/.config
	perl -i -p -e 's,^TARGET_ARCH.*,TARGET_ARCH=\"$(ARCH)\",g' $(UCLIBC_DIR)/.config
	perl -i -p -e 's,^KERNEL_SOURCE=.*,KERNEL_SOURCE=\"$(LINUX_DIR)\",g' \
		$(UCLIBC_DIR)/.config
	perl -i -p -e 's,^RUNTIME_PREFIX=.*,RUNTIME_PREFIX=\"/\",g' \
		$(UCLIBC_DIR)/.config
	perl -i -p -e 's,^DEVEL_PREFIX=.*,DEVEL_PREFIX=\"/\",g' \
		$(UCLIBC_DIR)/.config
	perl -i -p -e 's,^SHARED_LIB_LOADER_PREFIX=.*,SHARED_LIB_LOADER_PREFIX=\"/lib\",g' \
		$(UCLIBC_DIR)/.config
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) oldconfig
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) \
	PREFIX=$(STAGING_DIR)/ \
	CROSS_COMPILER_PREFIX="" \
	DEVEL_PREFIX=/ CC=$(HOSTCC) \
	RUNTIME_PREFIX=/ \
	pregen install_dev;
	touch $(UCLIBC_DIR)/.configured
#	CPU_CFLAGS-y="-mtune=$(GNU_TUNE)" \

# Set runtime prefix to STAGING_DIR for the host uClibc loader (see hack below)
$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured
#	$(MAKE) -C $(UCLIBC_DIR) \
#	PREFIX=$(STAGING_DIR)/ \
#	DEVEL_PREFIX=/ \
#	RUNTIME_PREFIX=$(STAGING_DIR)/ \
#	pregen install_dev;
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) \
	CPU_CFLAGS-y="-mtune=$(GNU_TUNE)" \
	PREFIX= \
	DEVEL_PREFIX=/ \
	RUNTIME_PREFIX=$(STAGING_DIR)/ \
	all

$(STAGING_DIR)/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) \
	CPU_CFLAGS-y="-mtune=$(GNU_TUNE)" \
	PREFIX= \
	DEVEL_PREFIX=$(STAGING_DIR)/ \
	RUNTIME_PREFIX=$(STAGING_DIR)/ \
	install_runtime install_dev 
	
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) \
	CPU_CFLAGS-y="-mtune=$(GNU_TUNE)" \
	PREFIX=$(STAGING_DIR) \
	install_utils 
	
	# Install uClibc loader for target system
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) clean
	$(MAKE) $(MAKEOPTS) -C $(UCLIBC_DIR) RUNTIME_PREFIX=/ CPU_CFLAGS-y="-mtune=$(GNU_TUNE)" all
	cp $(UCLIBC_DIR)/lib/ld-uClibc-* $(STAGING_DIR)/lib/ld-uClibc-target.so
	touch $(STAGING_DIR)/lib/libc.a

#ifneq ($(TARGET_DIR),)
#$(TARGET_DIR)/lib/libc.so.0: $(STAGING_DIR)/lib/libc.a
#	$(MAKE) -C $(UCLIBC_DIR) \
#		PREFIX=$(TARGET_DIR) \
#		RUNTIME_PREFIX=/ \
#		DEVEL_PREFIX=/usr/ \
#		install_runtime
#
#$(TARGET_DIR)/usr/bin/ldd: $(TARGET_DIR)/lib/libc.so.0
#	$(MAKE) -C $(UCLIBC_DIR) PREFIX=$(TARGET_DIR) utils install_utils
#	(cd $(TARGET_DIR)/sbin; ln -sf /bin/true ldconfig) 
#
#UCLIBC_TARGETS=$(TARGET_DIR)/lib/libc.so.0 $(TARGET_DIR)/usr/bin/ldd
#endif

uclibc-configured: $(UCLIBC_DIR)/.configured

uclibc: $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-gcc $(STAGING_DIR)/lib/libc.a \
	$(UCLIBC_TARGETS)

uclibc-clean:
	-$(MAKE) -C $(UCLIBC_DIR) clean
	rm -f $(UCLIBC_DIR)/.config

uclibc-dirclean:
	rm -rf $(UCLIBC_DIR)


#############################################################
#
# GMP is required by GCC
#
#############################################################
$(GMP_DIR)/.unpacked: 
	(cd $(GCC_DIR); bzcat ../$(GMP_SOURCE) | tar -xvf -)
	mv $(GMP_DIR)-$(GMP_VERSION) $(GMP_DIR)
	touch $(GMP_DIR)/.unpacked

gmp-source: $(GMP_DIR)/.unpacked

$(GMP_BUILD_DIR)/.configured: $(GMP_DIR)/.unpacked $(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/ld \
	 $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-gcc
	mkdir -p $(GMP_BUILD_DIR)
	(cd $(GMP_BUILD_DIR); CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS)" \
		$(GMP_DIR)/configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--enable-targets=$(GNU_TARGET_NAME) \
		--enable-shared \
		$(MULTILIB) )
	touch $(GMP_BUILD_DIR)/.configured

$(GMP_BUILD_DIR)/.libs/libgmp.a: $(GMP_BUILD_DIR)/.configured
	$(MAKE) $(MAKEOPTS) -C $(GMP_BUILD_DIR) all

$(STAGING_DIR)/usr/lib/libgmp.a: $(GMP_BUILD_DIR)/.libs/libgmp.a
	mkdir -p $(GMP_TARGET_DIR)
	$(MAKE) $(MAKEOPTS) DESTDIR=$(GMP_TARGET_DIR) -C $(GMP_BUILD_DIR) \
		install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(GMP_TARGET_DIR)/usr/lib/*
	-rm -rf $(GMP_TARGET_DIR)/usr/share
	cp -a $(GMP_TARGET_DIR)/* $(STAGING_DIR)

gmp-clean:
	-rm $(GMP_BUILD_DIR)

#gmp-dirclean:
#	rm -rf $(GMP_DIR)


#############################################################
#
# MPFR is required by GCC
#
#############################################################
$(MPFR_DIR)/.unpacked: 
	(cd $(GCC_DIR); bzcat ../$(MPFR_SOURCE) | tar -xvf - )
	mv $(MPFR_DIR)-$(MPFR_VERSION) $(MPFR_DIR)
	perl -i -p -e "s,(['"'"=: ])/(usr/)?lib,\1$(STAGING_DIR)/\2lib,g' \
		$(MPFR_DIR)/configure
	touch $(MPFR_DIR)/.unpacked

mpfr-source: $(MPFR_DIR)/.unpacked

#$(MPFR_DIR)/.configured: $(MPFR_DIR)/.unpacked $(GMP_DIR)/.build
#	(cd $(MPFR_DIR); CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS) -m32" \
#	LDFLAGS="-L$(STAGING_DIR)/lib" \
#	./configure --build=i386-pc-linux-gnu --host=i386-pc-linux-gnu --prefix=/ \
#		--with-gmp=$(STAGING_DIR))
#	touch $(MPFR_DIR)/.configured

#$(MPFR_DIR)/.build: $(MPFR_DIR)/.configured
#	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) CFLAGS="$(BT_COPT_FLAGS) -m32" \
#	LDFLAGS="-L$(STAGING_DIR)/lib" -C $(MPFR_DIR)
#	mkdir -p $(MPFR_TARGET_DIR)
#	$(MAKE) CC=$(TARGET_CC) CFLAGS=$(BT_COPT_CFLAGS) \
#	    DESTDIR=$(MPFR_TARGET_DIR) -C $(MPFR_DIR) install
#	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(MPFR_TARGET_DIR)/lib/*
#	-rm -rf $(MPFR_TARGET_DIR)/share
#	cp -a $(MPFR_TARGET_DIR)/* $(STAGING_DIR)
#	touch $(MPFR_DIR)/.build
	
#mpfr: $(MPFR_DIR)/.build

#mpfr-clean:
#	-$(MAKE) -C $(MPFR_DIR) clean

#mpfr-dirclean:
#	rm -rf $(MPFR_DIR)


#############################################################
#
# MPC is required by GCC
#
#############################################################
$(MPC_DIR)/.unpacked: 
	(cd $(GCC_DIR); zcat ../$(MPC_SOURCE) | tar -xvf -)
	mv $(MPC_DIR)-$(MPC_VERSION) $(MPC_DIR)
	perl -i -p -e "s,(['"'"=: ])/(usr/)?lib,\1$(STAGING_DIR)/\2lib,g' \
		$(MPC_DIR)/configure
	touch $(MPC_DIR)/.unpacked

mpc-source: $(MPC_DIR)/.unpacked


#############################################################
#
# second pass compiler build.  Build the compiler targeting 
# the newly built shared uClibc library.
#
#############################################################
GCC_BUILD_DIR2:=$(TOOL_BUILD_DIR)/gcc-$(GCC_VERSION)-final

$(GCC_DIR)/.g++_build_hacks: $(GCC_DIR)/.patched 
#$(GMP_DIR)/.build $(MPFR_DIR)/.build
	#
	# Hack up the soname for libstdc++
	# 
#	perl -i -p -e "s,SHLIB_SOVERSION = 1,SHLIB_SOVERSION = 0.9.9,g;" $(GCC_DIR)/gcc/config/t-slibgcc-elf-ver;
#	perl -i -p -e "s,-version-info.*[0-9]:[0-9]:[0-9],-version-info 9:9:0,g;" \
#		$(GCC_DIR)/libstdc++-v3/src/Makefile.am $(GCC_DIR)/libstdc++-v3/src/Makefile.in;
#	perl -i -p -e "s,3\.0\.0,9.9.0,g;" $(GCC_DIR)/libstdc++-v3/acinclude.m4 \
#		$(GCC_DIR)/libstdc++-v3/aclocal.m4 $(GCC_DIR)/libstdc++-v3/configure;
	#
	# For now, we don't support locale-ified ctype (we will soon), 
	# so bypass that problem for now...
	#
	perl -i -p -e "s,defined.*_GLIBCPP_USE_C99.*,1,g;" \
		$(GCC_DIR)/libstdc++-v3/config/locale/generic/c_locale.cc;
	cp $(GCC_DIR)/libstdc++-v3/config/os/generic/ctype_base.h \
		$(GCC_DIR)/libstdc++-v3/config/os/gnu-linux/
	cp $(GCC_DIR)/libstdc++-v3/config/os/generic/ctype_inline.h \
		$(GCC_DIR)/libstdc++-v3/config/os/gnu-linux/
	cp $(GCC_DIR)/libstdc++-v3/config/os/generic/ctype_noninline.h \
		$(GCC_DIR)/libstdc++-v3/config/os/gnu-linux/
	perl -i -p -e "s,wchar\.h,wchar-not-supported.h,g;" \
		$(GCC_DIR)/libstdc++-v3/configure;
	touch $(GCC_DIR)/.g++_build_hacks


$(GCC_BUILD_DIR2)/.configured: $(GCC_DIR)/.g++_build_hacks
	mkdir -p $(GCC_BUILD_DIR2)
	# Importants! Requierd for limits.h to be fixed.
	ln -snf ../include $(STAGING_DIR)/$(GNU_TARGET_NAME)/sys-include
	(cd $(GCC_BUILD_DIR2); PATH=$(TARGET_PATH) \
		AR=$(TARGET_CROSS)ar \
		RANLIB=$(TARGET_CROSS)ranlib \
		LD=$(TARGET_CROSS)ld \
		NM=$(TARGET_CROSS)nm  \
		CC="$(HOSTCC)" \
		CFLAGS="$(BT_COPT_FLAGS)" \
		$(GCC_DIR)/configure \
		--prefix=$(STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--exec-prefix=$(STAGING_DIR) \
		--bindir=$(STAGING_DIR)/bin \
		--sbindir=$(STAGING_DIR)/sbin \
		--sysconfdir=$(STAGING_DIR)/etc \
		--datadir=$(STAGING_DIR)/share \
		--localstatedir=$(STAGING_DIR)/var \
		--mandir=$(STAGING_DIR)/man \
		--infodir=$(STAGING_DIR)/info \
		--with-local-prefix=$(STAGING_DIR)/usr \
		--libdir=$(STAGING_DIR)/lib \
		--includedir=$(STAGING_DIR)/include \
		--with-gxx-include-dir=$(STAGING_DIR)/include/c++ \
		--oldincludedir=$(STAGING_DIR)/include \
		--enable-languages=$(TARGET_LANGUAGES) \
		--enable-shared \
		--disable-__cxa_atexit \
		--enable-target-optspace \
		--disable-nls \
		--with-gnu-ld \
		$(MULTILIB) \
		$(EXTRA_GCC_CONFIG_OPTIONS));
	touch $(GCC_BUILD_DIR2)/.configured

$(GCC_BUILD_DIR2)/.compiled: $(GCC_BUILD_DIR2)/.configured
	PATH=$(TARGET_PATH) CC=$(HOSTCC) CFLAGS="$(BT_COPT_FLAGS)" \
	    AR_FOR_TARGET=$(TARGET_CROSS)ar RANLIB_FOR_TARGET=$(TARGET_CROSS)ranlib \
	    LD_FOR_TARGET=$(TARGET_CROSS)ld NM_FOR_TARGET=$(TARGET_CROSS)nm \
	    CC_FOR_TARGET=$(TARGET_CROSS)gcc \
	    $(MAKE) $(MAKEOPTS) -C $(GCC_BUILD_DIR2) all
	touch $(GCC_BUILD_DIR2)/.compiled

$(GCC_BUILD_DIR2)/.installed: $(GCC_BUILD_DIR2)/.compiled
	touch $(GCC_BUILD_DIR2)/.installed


$(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-g++: $(GCC_BUILD_DIR2)/.compiled
	PATH=$(TARGET_PATH) $(MAKE) $(MAKEOPTS) -C $(GCC_BUILD_DIR2) install
#	if [ -d "$(STAGING_DIR)/lib64" ] ; then \
#	    if [ ! -e "$(STAGING_DIR)/lib" ] ; then \
#		mkdir "$(STAGING_DIR)/lib" ; \
#	    fi ; \
#	    mv "$(STAGING_DIR)/lib/"* "$(STAGING_DIR)/lib/" ; \
#	    rmdir "$(STAGING_DIR)/lib64" ; \
#	fi
	# Strip the host binaries
	-strip --strip-all -R .note -R .comment $(STAGING_DIR)/bin/*
	-strip --strip-unneeded $(STAGING_DIR)/lib/libstdc++.so*
	-strip --strip-unneeded $(STAGING_DIR)/lib/libgcc_s.so*
	
	# Make sure we have 'cc'.
	if [ ! -e $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-cc ] ; then \
		ln -snf $(GNU_TARGET_NAME)-gcc \
			$(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-cc ; \
	fi;
	if [ ! -e $(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/cc ] ; then \
		ln -snf gcc $(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/cc ; \
	fi

	-mv $(STAGING_DIR)/bin/gcc $(STAGING_DIR)/usr/bin;
	-mv $(STAGING_DIR)/bin/protoize $(STAGING_DIR)/usr/bin;
	-mv $(STAGING_DIR)/bin/unprotoize $(STAGING_DIR)/usr/bin;
	rm -f $(STAGING_DIR)/bin/cpp $(STAGING_DIR)/bin/gcov $(STAGING_DIR)/bin/*gccbug
	rm -rf $(STAGING_DIR)/info $(STAGING_DIR)/man $(STAGING_DIR)/share/doc \
		$(STAGING_DIR)/share/locale
	set -e; \
	for app in cc gcc c89 cpp c++ g++ ; do \
		if [ -x $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-$${app} ] ; then \
		    (cd $(STAGING_DIR)/usr/bin; \
			ln -fs ../../bin/$(GNU_TARGET_NAME)-$${app} $${app}; \
		    ); \
		fi; \
	done;

gcc_final: uclibc-configured $(STAGING_DIR)/.setup binutils gcc_initial uclibc $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)-g++

gcc_final-clean:
	rm -rf $(GCC_BUILD_DIR2)
	rm -f $(STAGING_DIR)/bin/$(GNU_TARGET_NAME)*

gcc_final-dirclean:
	rm -rf $(GCC_BUILD_DIR2)


########################### bering uclibc stuff
.source: .setup $(BINUTILS_DIR)/.patched $(UCLIBC_DIR)/.configured $(GCC_DIR)/.patched $(GMP_DIR)/.unpacked $(MPFR_DIR)/.unpacked $(MPC_DIR)/.unpacked
	touch .source

source: .source

shared_libs: $(STAGING_DIR)/lib/libbfd.a $(STAGING_DIR)/usr/lib/libgmp.a

.build: uclibc_toolchain shared_libs
	touch .build

.build2:
	env
	sed 

build: .build

clean: gcc_final-clean
	-rm .build
