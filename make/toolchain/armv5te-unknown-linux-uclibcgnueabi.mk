#
# Included Makefilefile for armv5te-unknown-linux-uclibcgnueabi toolchain
# Intended for ARM Versatile Platform Board target
#
ifeq ($(GNU_TARGET_NAME),armv5te-unknown-linux-uclibcgnueabi)
# Kernel versions
export BT_KERNEL_BRANCH:=3.4
export BT_KERNEL_PATCH:=68
# Primary kernel architecture
export ARCH:=arm
# Arch for includes symlink
export ARCH_INC:=arm
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
# Fix "checking packing order of bit fields... no defaults for cross-compiling"
export rpppoe_cv_pack_bitfields=rev
# Fix "WARNING: cross compiling; assuming big endianess"
export gnupg_cv_c_endian=little
endif

endif
