# this is the Master make file that should be included by all the makefiles
# used for buildroot...

#export vars only if this is not a toolchain building
ifndef GCC_SOURCE
#cross-compile fix
export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes
export ac_cv_va_copy=C99
export ac_cv_sys_restartable_syscalls=yes
export ac_cv_func_setpgrp_void=yes
export ac_cv_file__dev_random=yes
endif

# we assume that we have the target root dir as environment var
# and also GNU_TARGET_NAME which is set by buildtool.pl
# where the sources are
export BT_SOURCE_DIR=$(BT_BUILDROOT)/source/$(GNU_TARGET_NAME)
# where the buildstuff goes into
export BT_BUILD_DIR=$(BT_BUILDROOT)/build/$(GNU_TARGET_NAME)
export BT_BUILDDIR=$(BT_BUILDROOT)/build/$(GNU_TARGET_NAME)
export BT_STAGING_DIR:=$(BT_BUILDROOT)/staging/$(GNU_TARGET_NAME)
# where are the linux sources
export BT_LINUX_DIR:=$(BT_SOURCE_DIR)/linux/linux
# where to put finished packages
export BT_PACKAGE_DIR:=$(BT_BUILDROOT)/package/$(GNU_TARGET_NAME)
# toolsdir
export BT_TOOLS_DIR:=$(BT_BUILDROOT)/tools
# where to find the patchtool
export BT_PATCHTOOL:=$(BT_TOOLS_DIR)/make-patches.sh
#  where is dpatch
export BT_DPATCH=$(BT_TOOLS_DIR)/dpatch 
# getdirname tool
export BT_TGZ_GETDIRNAME=$(BT_TOOLS_DIR)/getdirname.pl

########################################

ifeq ($(GNU_TARGET_NAME),i486-unknown-linux-uclibc)
# primary kernel arch
export ARCH:=i386
# available kernel archs
export KARCHS:=i686 i486 geode
# available kernel archs with pci-express support
export KARCHS_PCIE:=i686
# set target subarch here
export GNU_ARCH:=i486
# set target optimization here
export GNU_TUNE:=pentiumpro

# Export cross-compile arch-dependent vars
# only if this is not a toolchain building
ifndef GCC_SOURCE
export ac_cv_libnet_endianess=lil
export ac_cv_c_bigendian=no
export rpppoe_cv_pack_bitfields=rev
export gnupg_cv_c_endian=little
export ac_cv_sizeof_int=4
export ac_cv_sizeof_long=4
export ac_cv_sizeof_short=2
endif

# === sample for second arch ====
else ifeq ($(GNU_TARGET_NAME),x86_64-unknown-linux-uclibc)
# primary kernel arch
export ARCH:=x86_64
# available kernel archs
export KARCHS:=x86_64
# set target subarch here
export GNU_ARCH:=generic
# set target optimization here
export GNU_TUNE:=generic

# Export cross-compile arch-dependent vars
# only if this is not a toolchain building
ifndef GCC_SOURCE
export ac_cv_libnet_endianess=lil
export ac_cv_c_bigendian=no
export rpppoe_cv_pack_bitfields=rev
export gnupg_cv_c_endian=little
export ac_cv_sizeof_int=4
export ac_cv_sizeof_long=8
export ac_cv_sizeof_short=2
endif

endif

# arch of build system
GNU_BUILD_NAME=$(shell LANG=C gcc -v 2>&1|awk '/Target:/ {print $$2}')
# arch of target system - dMb: now set via buildtool.pl & buildtool.conf
##export GNU_TARGET_NAME=$(GNU_ARCH)-pc-linux-uclibc
# target gcc
export TARGET_CC=$(GNU_TARGET_NAME)-gcc
export TARGET_CXX=$(GNU_TARGET_NAME)-g++
# target ld
export TARGET_LD=$(GNU_TARGET_NAME)-ld

export TARGET_AR=$(GNU_TARGET_NAME)-ar
export TARGET_RANLIB=$(GNU_TARGET_NAME)-ranlib
# for dpatch (debian patch)
export DEB_BUILD_ARCH=$(ARCH)
# strip
export BT_STRIP:=$(GNU_TARGET_NAME)-strip
export BT_STRIP_LIBOPTS:=--strip-unneeded 
export BT_STRIP_BINOPTS:=-s --remove-section=.note --remove-section=.comment

#ranlib
export BT_RANLIB:=$(GNU_TARGET_NAME)-ranlib

##########################################
#Toolchain dir
export TOOLCHAIN_DIR=$(BT_BUILDROOT)/toolchain/$(GNU_TARGET_NAME)

#Paths
export PATH:=$(TOOLCHAIN_DIR)/bin:$(TOOLCHAIN_DIR)/usr/bin:$(PATH)
export PKG_CONFIG_PATH=$(BT_STAGING_DIR)/usr/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$(BT_STAGING_DIR)/usr/lib/pkgconfig

#Cross-compile target
export CROSS_COMPILE=$(GNU_TARGET_NAME)-

#make options
CPUCOUNT=$(shell cat /proc/cpuinfo | grep processor | wc -l)
export MAKEOPTS:=-j$(shell echo $$(($(CPUCOUNT)+1)))

# hack for RH 9 systems - perl seems to have a problem with UTF8
export LANG=en_US

# default optimization settings for compiling code 
export CFLAGS=-O2 -march=$(GNU_ARCH) -mtune=$(GNU_TUNE) -I$(BT_STAGING_DIR)/usr/include
export CPPFLAGS=-I$(BT_STAGING_DIR)/usr/include

# default ld flags
export LDFLAGS=-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib
EXTCCLDFLAGS=-Wl,-rpath,$(BT_STAGING_DIR)/lib -Wl,-rpath,$(BT_STAGING_DIR)/usr/lib
EXTLDFLAGS=-rpath $(BT_STAGING_DIR)/lib -rpath $(BT_STAGING_DIR)/usr/lib

# check for linux version

export FIRSTKARCH=$(shell echo $(KARCHS)|awk '{if (NF>0) print "-" $$1}')
BT_KERNEL_RELEASE1=$(shell cat $(BT_SOURCE_DIR)/linux/linux$(FIRSTKARCH)/.config | awk '/Linux.*Kernel Configuration/ {print $$3}')
export BT_KERNEL_RELEASE=$(shell echo ${BT_KERNEL_RELEASE1})
export ac_cv_linux_vers=$(BT_KERNEL_RELEASE)

#BT_DEPMOD=$(BT_STAGING_DIR)/sbin/depmod

