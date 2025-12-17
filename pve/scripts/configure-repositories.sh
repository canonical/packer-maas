sed -i "s/^deb/\#deb/" /etc/apt/sources.list.d/pve-enterprise.list
sed -i "s/^deb/\#deb/" /etc/apt/sources.list.d/ceph.list
echo "deb http://download.proxmox.com/debian/pve $(grep "VERSION=" /etc/os-release | sed -n 's/.*(\(.*\)).*/\1/p') pve-no-subscription" > /etc/apt/sources.list.d/pve-no-enterprise.list
apt update
apt install -y cloud-init