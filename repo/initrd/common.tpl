<initrd-##ARCH##>
	packagetype = initrd
	packagename = initrd

	Version = 5.0-prealpha
	Revision = 2

	Help <<EOF
	LEAF Bering-uClibc initial filesystem (floppy + IDE/SATA + USB)
	Required for the ##ARCH##-optimized kernel.

	This is not an ordinary *.LRP package !
	LEAF package by __PACKAGER__, __BUILDDATE__
	EOF

	<Permissions>
		Files = 644
		Directories = 755
	</Permissions>

	<Owner>
		Files = root:root
		Directories = root:root
	</Owner>

	<Contents>
		<File>
			Filename	= dev/console
			Type		= device
			devtype 	= c 
			major 		= 5 
			minor		= 1
			Permissions	= 644
		</File>
		<File>
			Source		= lib/ld-uClibc-0.9.32.1.so
			Filename	= lib/ld-uClibc-0.9.32.1.so
			Type		= binary
			Permissions	= 755
		</File>
		<File>
			Source		= lib/librt-0.9.32.1.so
			Filename	= lib/librt-0.9.32.1.so
			Type		= binary
			Permissions	= 644
		</File>
		<File>
			Filename	= lib/librt.so.0
			Target		= lib/librt-0.9.32.1.so
			Type		= link
		</File>
		<File>
			Source		= lib/libcrypt-0.9.32.1.so
			Filename	= lib/libcrypt-0.9.32.1.so
			Type		= binary
			Permissions	= 644
		</File>
		<File>
			Source		= lib/libuClibc-0.9.32.1.so
			Filename	= lib/libuClibc-0.9.32.1.so
			Type		= binary
			Permissions	= 644
		</File>
		<File>
			Filename	= lib/libcrypt.so.0
			Target		= lib/libcrypt-0.9.32.1.so
			Type		= link
		</File>
		<File>
			Filename	= lib/ld-uClibc.so.0
			Target		= lib/ld-uClibc-0.9.32.1.so
			Type		= link
		</File>
		<File>
			Filename	= lib/libc.so.0
			Target		= lib/libuClibc-0.9.32.1.so
			Type		= link
		</File>
		<File>
			Filename	= lib/libgcc_s.so.1
			Source		= lib/libgcc_s.so.1
			Type		= binary
			Permissions	= 755
		</File>
		<File>
			Filename	= lib/libgcc_s.so
			Target		= lib/libgcc_s.so.1
			Type		= link
		</File>
		<File>
			Source		= bin/busybox
			Filename	= bin/busybox
			Type		= binary
			Permissions 	= 4755
		</File>
		<File>
			Filename	= sbin
			Type		= directory
			Permissions	= 755
		</File>
		<File>
			Source		= boot/etc/README
			Filename	= boot/etc/README
			Type		= binary
			Permissions 	= 644
		</File>
		<File>
			Filename	= boot/lib/modules
			Type		= directory
			Permissions	= 755
		</File>
		<File>
			Filename	= lib/modules
			Type		= directory
			Permissions	= 755
		</File>
		<File>
			Filename	= usr/bin
			Type		= directory
			Permissions	= 755
		</File>
		<File>
			Filename	= usr/sbin
			Type		= directory
			Permissions	= 755
		</File>
		<File>
			Filename	= var/log
			Type		= directory
			Permissions	= 755
		</File>
		<File>
			Source		= var/lib/lrpkg/root.linuxrc
			Filename	= var/lib/lrpkg/root.linuxrc
			Type		= binary
			Permissions	= 755
		</File>
		<File>
			Source		= var/lib/lrpkg/root.helper
			Filename	= var/lib/lrpkg/root.helper
			Type		= binary
			Permissions	= 755
		</File>
		<File>
			Source		= sbin/hotplug.sh
			Filename	= sbin/hotplug.sh
			Type		= binary
			Permissions	= 755
		</File>
		<File>
			Filename	= init
			Target		= var/lib/lrpkg/root.linuxrc
			Type		= link
		</File>
		<File>
			Source		= boot/etc/modules
			Filename	= boot/etc/modules
			Type		= binary
			Description	= Modules to load before any other package
		</File>
		#include <files.##ARCH##>
	</Contents>
</initrd-##ARCH##>
