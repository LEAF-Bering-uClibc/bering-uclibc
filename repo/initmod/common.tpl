<initmod-##ARCH##>
	packagetype = initrd
	packagename = initmod

	Version =  __KVER__-##ARCH##
	Revision = 4
	License = LEAF-INITRD

	Help <<EOF
	LEAF Bering-uClibc modules for initial filesystem (floppy + IDE/SATA + USB)
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
		?include <files.##ARCH##>
	</Contents>
</initrd-##ARCH##>
