install
# Poweroff after installation
poweroff
# System authorization information
auth --enableshadow --passalgo=sha512
# Firewall configuration
firewall --enabled --service=ssh
firstboot --disable
ignoredisk --only-use=vda
# Keyboard layouts
# old format: keyboard us
# new format:
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
repo --name "os" --baseurl="http://mirror.centos.org/centos/7/os/x86_64"
repo --name "updates" --baseurl="http://mirror.centos.org/centos/7/updates/x86_64"
repo --name "extras" --baseurl="http://mirror.centos.org/centos/7/extras/x86_64"
repo --name "cloud-init" --baseurl="http://copr-be.cloud.fedoraproject.org/results/@cloud-init/el-stable/epel-7-x86_64"
# Network information
network  --bootproto=dhcp --device=eth0 --onboot=on
# System bootloader configuration
bootloader --append="console=ttyS0,115200n8 console=tty0" --location=mbr --driveorder="vda" --timeout=1
# Root password
rootpw --iscrypted nothing
selinux --enforcing
services --disabled="kdump" --enabled="network,sshd,rsyslog,chronyd"
timezone UTC --isUtc
# Disk
zerombr
clearpart --all --initlabel
part / --fstype=ext4 --size=4000

%post --erroronfail

# workaround anaconda requirements
passwd -d root
passwd -l root

# remove avahi and networkmanager
echo "Removing avahi/zeroconf and NetworkManager"
yum -C -y remove avahi\* Network\*

echo "Cleaning old yum repodata."
yum clean all

# chance dhcp client retry/timeouts to resolve #6866
cat  >> /etc/dhcp/dhclient.conf << EOF

timeout 300;
retry 60;
EOF

# clean up /etc/resolv.conf
rm /etc/resolv.conf
touch /etc/resolv.conf
chown root:root /etc/resolv.conf
chmod 644 /etc/resolv.conf

# clean up installation logs"
rm -rf /var/log/yum.log
rm -rf /var/lib/yum/*
rm -rf /root/install.log
rm -rf /root/install.log.syslog
rm -rf /root/anaconda-ks.cfg
rm -rf /var/log/anaconda*
rm -rf /root/anac*

echo "Fixing SELinux contexts."
touch /var/log/cron
touch /var/log/boot.log
mkdir -p /var/cache/yum
/usr/sbin/fixfiles -R -a restore

# reorder console entries
sed -i 's/console=tty0/console=tty0 console=ttyS0,115200n8/' /boot/grub2/grub.cfg

echo "Removing installation network config."
rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

%end

%packages
@core
bash-completion
chrony
cloud-init-el-release
cloud-init
# cloud-init only requires python-oauthlib with MAAS. As such upstream
# has removed python-oauthlib from cloud-init's deps.
python-oauthlib
cloud-utils-growpart
dracut-config-generic
dracut-norescue
firewalld
kernel
rsync
tar
yum-utils
# bridge-utils is required by cloud-init to configure networking. Without it
# installed cloud-init will try to install it itself which will not work in
# isolated environments.
bridge-utils
# Tools needed to allow custom storage to be deployed without acessing the
# Internet.
# grub2-efi-x64 contains the signed bootloader which currently does not
# chainboot - RHBZ #1623296
# grub2-efi-x64
# shim-x64
# RHBZ #1101352
grub2-efi-x64-modules
grub2-tools
efibootmgr
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-NetworkManager
-aic94xx-firmware
-alsa-firmware
-alsa-lib
-alsa-tools-firmware
-iprutils
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-iwl7265-firmware
-libertas-sd8686-firmware
-libertas-sd8787-firmware
-libertas-usb8388-firmware
-plymouth
-postfix
-wpa_supplicant

%end
