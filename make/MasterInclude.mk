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
export ac_cv_func_regcomp=yes
export ac_cv_printf_positional=yes
# Persuade krb5's configure that libldap does in fact have ldap_init() and ldap_initialize()
export ac_cv_lib_ext_ldap_ldap_init=yes
export ac_cv_func_ldap_initialize=yes
# Persuade samba's configure that libldap does in fact have ldap_init() and ldap_initialize()
export ac_cv_lib_ldap_ldap_init=yes
export ac_cv_func_ext_ldap_initialize=yes
export ac_cv_func_ext_ldap_add_result_entry=yes
# Persuade radius' configure that libldap_r does in fact have ldap_init()
export ac_cv_lib_ldap_r_ldap_init=yes
endif

# We assume we have the BT_XXXX variables and the target platform name (GNU_TARGET_NAME)
# as environment variables, all set by buildtool.pl
#
# Where the linux sources are
export BT_LINUX_DIR:=$(BT_SOURCE_DIR)/linux/linux
# Where to find the patchtool
export BT_PATCHTOOL:=$(BT_TOOLS_DIR)/make-patches.sh
# Where to find dpatch
export BT_DPATCH=$(BT_TOOLS_DIR)/dpatch 
# Where to find the getdirname tool
export BT_TGZ_GETDIRNAME=$(BT_TOOLS_DIR)/getdirname.pl
# Where to find the setup-builddir tool
export BT_SETUP_BUILDDIR=$(BT_TOOLS_DIR)/setup-builddir
# Where to find the get-kernel-version tool
export BT_GET_KERNEL_VERSION=$(BT_TOOLS_DIR)/get-kernel-version

# Include per-toolchain Makefiles
include $(BT_BUILDROOT)/make/toolchain/*.mk

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

# Paths
export PATH:=$(BT_TOOLCHAIN_DIR)/bin:$(BT_TOOLCHAIN_DIR)/usr/bin:$(PATH)
export PKG_CONFIG_PATH=$(BT_STAGING_DIR)/usr/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$(BT_STAGING_DIR)/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=$(BT_STAGING_DIR)

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
export BT_KERNEL_RELEASE=$(BT_KERNEL_BRANCH).$(BT_KERNEL_PATCH)
export ac_cv_linux_vers=$(BT_KERNEL_RELEASE)

kversion:
	echo -n $(BT_KERNEL_RELEASE)

kbranch:
	echo -n $(BT_KERNEL_BRANCH)
