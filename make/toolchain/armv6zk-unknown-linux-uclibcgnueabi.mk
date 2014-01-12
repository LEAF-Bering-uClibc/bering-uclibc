#
# Included Makefilefile for armv6zk-unknown-linux-uclibcgnueabi toolchain
# Intended for Raspberry Pi target
#
ifeq ($(GNU_TARGET_NAME),armv6zk-unknown-linux-uclibcgnueabi)
# Primary kernel architecture
export ARCH:=arm
# Space-separated list of kernel sub-archs to generate
export KARCHS:=bcmrpi
# Arch-specific CFLAGS
export ARCH_CFLAGS:=-march=armv6zk -mtune=arm1176jzf-s -mfpu=vfp -mfloat-abi=softfp
# Name of kernel image
export KERN_IMAGE:=zImage
# Name of OpenSSL target
export OPENSSL_TARGET:=linux-armv4

# use nano for arm (used in etc.lrp /etc/profile)
export ARM_EDITOR:=nano

# Primary kernel architecture for U-Boot
export UBOOT_ARCH:=arm
export UBOOT_BOARDTYPE:=rpi_b

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

endif
