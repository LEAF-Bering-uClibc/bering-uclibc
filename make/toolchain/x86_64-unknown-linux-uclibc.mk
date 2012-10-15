#
# Included Makefilefile for x86_64-unknown-linux-uclibc toolchain
# Intended for generic x86_64 target
#
ifeq ($(GNU_TARGET_NAME),x86_64-unknown-linux-uclibc)
# Primary kernel architecture
export ARCH:=x86_64
# Space-separated list of kernel sub-archs to generate
export KARCHS:=x86_64
# Available kernel archs with pci-express support
export KARCHS_PCIE:=x86_64
# Arch-specific CFLAGS
export ARCH_CFLAGS:=-mtune=generic
# Name of kernel image
export KERN_IMAGE:=bzImage
# Name of OpenSSL target
export OPENSSL_TARGET:=linux-x86_64
# Compile a pure 64bits toolchain
export GCC_PURE64:=yes

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
export ac_cv_sizeof_int=4
export ac_cv_sizeof_long=8
export ac_cv_sizeof_short=2
endif

endif
