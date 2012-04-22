#
# Included Makefilefile for i486-unknown-linux-uclibc toolchain
# Intended for generic x86 target
#
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

endif
