<moddb-##KARCH##>
	Version  = __KVER__-##KARCH##
	Revision = 1

	Help <<EOF
		Modules for the ##KARCH##-optimized kernel.
		Modules to be used are defined in /etc/modules.
		Modules copied to /lib/modules are backed-up with this package.
		LRP package by __PACKAGER__, __BUILDDATE__
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
		?include <files.##KARCH##>
	</Contents>
</moddb-##KARCH##>
