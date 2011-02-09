#
# mountall.sh	Mount all filesystems.
#
RCDLINKS="S,S35"

#
# Mount local file systems in /etc/fstab.
#
echo "Mounting local file systems..."
mount -a
