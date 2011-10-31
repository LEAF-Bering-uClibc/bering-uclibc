# this is the Master make file that should be included by all the makefiles
# used for buildroot...

# set arch here - temporary
export ARCH:=i386


# where the sources are
export BT_SOURCE_DIR=$(BT_BUILDROOT)/source
# where the buildstuff goes into
export BT_BUILD_DIR=$(BT_BUILDROOT)/build
export BT_BUILDDIR=$(BT_BUILDROOT)/build
# we assume that we have the global root dir for buildtool as environment var
export BT_STAGING_DIR:=$(BT_BUILDROOT)/staging/$(ARCH)
# where are the linux sources
export BT_LINUX_DIR:=$(BT_SOURCE_DIR)/linux/linux
# where to put finished packages
export BT_PACKAGE_DIR:=$(BT_BUILDROOT)/package
# toolsdir
export BT_TOOLS_DIR:=$(BT_BUILDROOT)/tools
# where to find the patchtool
export BT_PATCHTOOL:=$(BT_TOOLS_DIR)/make-patches.sh
#  where is dpatch 
export BT_DPATCH=$(BT_TOOLS_DIR)/dpatch 
# getdirname tool
export BT_TGZ_GETDIRNAME=$(BT_TOOLS_DIR)/getdirname.pl

########################################
# available kernel archs
export KARCHS:=i686 i486 geode
# set target subarch here
export GNU_ARCH:=i486
# set target optimization here
export GNU_TUNE:=pentiumpro
#
export GNU_TARGET_NAME:=$(GNU_ARCH)-pc-linux-uclibc
# target gcc
export TARGET_CC:=$(GNU_TARGET_NAME)-gcc
# target ld
export TARGET_LD:=$(GNU_TARGET_NAME)-ld
# for dpatch (debian patch)
export DEB_BUILD_ARCH=$(ARCH)
# strip
export BT_STRIP:=$(GNU_TARGET_NAME)-strip
export BT_STRIP_LIBOPTS:=--strip-unneeded 
export BT_STRIP_BINOPTS:=-s --remove-section=.note --remove-section=.comment

##########################################
#Toolchain dir
export TOOLCHAIN_DIR=$(BT_BUILDROOT)/toolchain/$(ARCH)
#Paths
export PATH:=$(TOOLCHAIN_DIR)/sbin:$(TOOLCHAIN_DIR)/bin:$(TOOLCHAIN_DIR)/usr/sbin:$(TOOLCHAIN_DIR)/usr/bin:$(PATH)

#make options
CPUCOUNT=$(shell ls /sys/class/cpuid/ | wc -w)
export MAKEOPTS:=-j$(shell echo $$(($(CPUCOUNT)+1)))

# hack for RH 9 systems - perl seems to have a problem with UTF8
export LANG=en_US

# default optimization settings for compiling code 
export BT_COPT_FLAGS=-O2 -march=$(GNU_ARCH) -mtune=$(GNU_TUNE)

# default ld flags
export BT_LDFLAGS=-L$(BT_STAGING_DIR)/lib -L$(BT_STAGING_DIR)/usr/lib

# check for linux version

export FIRSTKARCH=$(shell echo $(KARCHS)|awk '{if (NF>0) print "-" $$1}')
BT_KERNEL_RELEASE1=$(shell cat $(BT_SOURCE_DIR)/linux/linux$(FIRSTKARCH)/.config | awk '/version:/ {print $$5}')
export BT_KERNEL_RELEASE=$(shell echo ${BT_KERNEL_RELEASE1})

BT_DEPMOD=$(BT_STAGING_DIR)/sbin/depmod

