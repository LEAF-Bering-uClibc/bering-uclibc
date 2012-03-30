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
		#include <files.##KARCH##>
#		<File>
#			Source		= lib/modules/__KVER__-##KARCH##/kernel/net/ipv4/*.ko.gz
#			Filename	= lib/modules/
#			Type		= binary
#			Permissions	= 644
#		</File>
#		<File>
#			Source		= lib/modules/__KVER__-##KARCH##/kernel/net/ipv6/*.ko.gz
#			Filename	= lib/modules/
#			Type		= binary
#			Permissions	= 644
#		</File>
#		<File>
#			Source		= lib/modules/__KVER__-##KARCH##/kernel/net/netfilter/*.ko.gz
#			Filename	= lib/modules/
#			Type		= binary
#			Permissions	= 644
#		</File>
#		<File>
#			Source		= lib/modules/__KVER__-##KARCH##/kernel/net/ipv4/netfilter/*.ko.gz
#			Filename	= lib/modules/
#			Type		= binary
#			Permissions	= 644
#		</File>
#		<File>
#			Source		= lib/modules/__KVER__-##KARCH##/kernel/net/ipv6/netfilter/*.ko.gz
#			Filename	= lib/modules/
#			Type		= binary
#			Permissions	= 644
#		</File>
		<File>
			Source		= lib/modules/__KVER__-##KARCH##/kernel/drivers/cpufreq/*.ko.gz
			Filename	= lib/modules/
			Type		= binary
			Permissions	= 644
		</File>
		<File>
			Source		= lib/firmware/e100/*.bin
			Filename	= lib/firmware/e100/
			Type		= binary
			Permissions	= 644
		</File>
	</Contents>
</moddb-##KARCH##>
