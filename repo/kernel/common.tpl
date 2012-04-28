	<kdebuginfo-##KARCH##>
		Version = __KVER__-##KARCH##
		Revision = 1
		Help <<EOF
		Kernel debug info for perf (##KARCH##)
		LEAF package by __PACKAGER__, __BUILDDATE__
		EOF

		<Permissions>
			Files = 750
			Directories = 750
		</Permissions>

		<Owner>
			Files = root:root
			Directories = root:root
		</Owner>

		<Contents>
			<File>
				Source		= lib/modules/__KVER__-##KARCH##/build/vmlinux
				Filename	= lib/modules/build/vmlinux
				Type		= binary
				Type		= module
			</File>
		</Contents>
	</kdebuginfo-##KARCH##>
