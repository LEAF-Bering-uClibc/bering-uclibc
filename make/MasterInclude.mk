###############################################################################
#
# Master make file that must be included by all the other buildtool.mk files
#
###############################################################################

# Set variables to "prime" the configure scripts' cache for cross-compiling
# These are Generic settings - Toolchain-specific settings go later in the file
# Export vars only if this is not a toolchain building
ifndef GCC_SOURCE
export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes
export ac_cv_va_copy=C99
export ac_cv_sys_restartable_syscalls=yes
export ac_cv_func_setpgrp_void=yes
export ac_cv_file__dev_random=yes
# Persuade radius' configure that libldap_r does in fact have ldap_init()
export ac_cv_lib_ldap_r_ldap_init=yes
endif

# We assume we have the target root dir (BT_BUILDROOT) and the target platform
# name (GNU_TARGET_NAME) as environment variables, both set by buildtool.pl
#
# Where the sources are
export BT_SOURCE_DIR=$(BT_BUILDROOT)/source/$(GNU_TARGET_NAME)
# Where the buildstuff goes into
export BT_BUILD_DIR=$(BT_BUILDROOT)/build/$(GNU_TARGET_NAME)
export BT_BUILDDIR=$(BT_BUILDROOT)/build/$(GNU_TARGET_NAME)
export BT_STAGING_DIR:=$(BT_BUILDROOT)/staging/$(GNU_TARGET_NAME)
# Where the linux sources are
export BT_LINUX_DIR:=$(BT_SOURCE_DIR)/linux/linux
# Where to put finished packages
export BT_PACKAGE_DIR:=$(BT_BUILDROOT)/package/$(GNU_TARGET_NAME)
# Where the tools are
export BT_TOOLS_DIR:=$(BT_BUILDROOT)/tools
# Where to find the patchtool
export BT_PATCHTOOL:=$(BT_TOOLS_DIR)/make-patches.sh
# Where to find dpatch
export BT_DPATCH=$(BT_TOOLS_DIR)/dpatch 
# Where to find the getdirname tool
export BT_TGZ_GETDIRNAME=$(BT_TOOLS_DIR)/getdirname.pl


# Default toolchain configuration

ifeq ($(GNU_TARGET_NAME),i486-unknown-linux-uclibc)
# Primary kernel architecture
export ARCH:=i386
# Space-separated list of kernel sub-archs to generate
export KARCHS:=i686 i486 geode
# Available kernel archs with pci-express support
export KARCHS_PCIE:=i686
# Arch-specific CFLAGS
export ARCH_CFLAGS:=-march=i486 -mtune=pentiumpro
# Name of kernel image
export KERN_IMAGE:=bzImage
# Name of OpenSSL target
export OPENSSL_TARGET:=linux-elf

# Set variables to "prime" the configure scripts' cache for cross-compiling
# These are toolchain-specific settings - generic settings go above
# Export vars only if this is not a toolchain building
ifndef GCC_SOURCE
# Generic endianness setting used by many applications
export ac_cv_c_bigendian=no
# Fix ../include/libnet.h:117:10: error: macro names must be identifiers
export ac_cv_libnet_endianess=lil
# Fix "checking packing order of bit fields... no defaults for cross-compiling"
export rpppoe_cv_pack_bitfields=rev
# Fix "WARNING: cross compiling; assuming big endianess"
export gnupg_cv_c_endian=little
export ac_cv_sizeof_int=4
export ac_cv_sizeof_long=4
export ac_cv_sizeof_short=2
endif

# Alternate toolchain configuration #1

else ifeq ($(GNU_TARGET_NAME),armv5te-unknown-linux-uclibcgnueabi)
# Primary kernel architecture
export ARCH:=arm
# Space-separated list of kernel sub-archs to generate
export KARCHS:=versatile
# Arch-specific CFLAGS
export ARCH_CFLAGS:=-march=armv5te -mtune=arm926ej-s
# Name of kernel image
export KERN_IMAGE:=zImage
# Name of OpenSSL target
export OPENSSL_TARGET:=linux-armv4

# Set variables to "prime" the configure scripts' cache for cross-compiling
# These are toolchain-specific settings - generic settings go above
# Export vars only if this is not a toolchain building
ifndef GCC_SOURCE
# Generic endianness setting used by many applications
export ac_cv_c_bigendian=no
# Fix "../include/libnet.h:117:10: error: macro names must be identifiers"
export ac_cv_libnet_endianess=lil
# Fix "checking packing order of bit fields... no defaults for cross-compiling"
export rpppoe_cv_pack_bitfields=rev
# Fix "WARNING: cross compiling; assuming big endianess"
export gnupg_cv_c_endian=little
endif

# Alternate toolchain configuration #2

else ifeq ($(GNU_TARGET_NAME),x86_64-unknown-linux-uclibc)
# Primary kernel architecture
export ARCH:=x86_64
# Space-separated list of kernel sub-archs to generate
export KARCHS:=x86_64
# Arch-specific CFLAGS
export ARCH_CFLAGS:=-march=generic -mtune=generic
# Name of kernel image
export KERN_IMAGE:=bzImage
# Name of OpenSSL target
export OPENSSL_TARGET:=linux-elf

# Set variables to "prime" the configure scripts' cache for cross-compiling
# These are toolchain-specific settings - generic settings go above
# Export vars only if this is not a toolchain building
ifndef GCC_SOURCE
# Generic endianness setting used by many applications
export ac_cv_c_bigendian=no
# Fix ../include/libnet.h:117:10: error: macro names must be identifiers
export ac_cv_libnet_endianess=lil
# Fix "checking packing order of bit fields... no defaults for cross-compiling"
export rpppoe_cv_pack_bitfields=rev
# Fix "WARNING: cross compiling; assuming big endianess"
export gnupg_cv_c_endian=little
export ac_cv_sizeof_int=4
export ac_cv_sizeof_long=8
export ac_cv_sizeof_short=2
endif

endif

# Arch of build system
GNU_BUILD_NAME=$(shell LANG=C gcc -v 2>&1|awk '/Target:/ {print $$2}')
# Arch of target system is now set via buildtool.pl & buildtool.conf
##export GNU_TARGET_NAME=$(GNU_ARCH)-pc-linux-uclibc
# Target gcc
export TARGET_CC=$(GNU_TARGET_NAME)-gcc
export TARGET_CXX=$(GNU_TARGET_NAME)-g++
# Target ld
export TARGET_LD=$(GNU_TARGET_NAME)-ld
# Target ar
export TARGET_AR=$(GNU_TARGET_NAME)-ar
# Target ranlib
export TARGET_RANLIB=$(GNU_TARGET_NAME)-ranlib
export BT_RANLIB:=$(GNU_TARGET_NAME)-ranlib
# For dpatch (debian patch)
export DEB_BUILD_ARCH=$(ARCH)
# Strip variables
export BT_STRIP:=$(GNU_TARGET_NAME)-strip
export BT_STRIP_LIBOPTS:=--strip-unneeded 
export BT_STRIP_BINOPTS:=-s --remove-section=.note --remove-section=.comment

# Toolchain dir
export TOOLCHAIN_DIR=$(BT_BUILDROOT)/toolchain/$(GNU_TARGET_NAME)

# Paths
export PATH:=$(TOOLCHAIN_DIR)/bin:$(TOOLCHAIN_DIR)/usr/bin:$(PATH)
export PKG_CONFIG_PATH=$(BT_STAGING_DIR)/usr/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$(BT_STAGING_DIR)/usr/lib/pkgconfig

# Cross-compile target
export CROSS_COMPILE=$(GNU_TARGET_NAME)-

# Make options
CPUCOUNT=$(shell cat /proc/cpuinfo | grep processor | wc -l)
export MAKEOPTS:=-j$(shell echo $$(($(CPUCOUNT)+1)))

# Hack for RH 9 systems - perl seems to have a problem with UTF8
export LANG=en_US

# Default settings for compiling code 
export CFLAGS=-O2 $(ARCH_CFLAGS) -I$(BT_STAGING_DIR)/usr/include
export CPPFLAGS=-I$(BT_STAGING_DIR)/usr/include

# Default ld flags
export LDFLAGS=-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib
EXTCCLDFLAGS=-Wl,-rpath,$(BT_STAGING_DIR)/lib -Wl,-rpath,$(BT_STAGING_DIR)/usr/lib
EXTLDFLAGS=-rpath $(BT_STAGING_DIR)/lib -rpath $(BT_STAGING_DIR)/usr/lib

# Check for linux version
export FIRSTKARCH=$(shell echo $(KARCHS)|awk '{if (NF>0) print "-" $$1}')
BT_KERNEL_RELEASE1=$(shell cat $(BT_SOURCE_DIR)/linux/linux$(FIRSTKARCH)/.config | awk '/Linux.*Kernel Configuration/ {print $$3}')
export BT_KERNEL_RELEASE=$(shell echo ${BT_KERNEL_RELEASE1})
export ac_cv_linux_vers=$(BT_KERNEL_RELEASE)

