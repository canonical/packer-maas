url --url=https://dl.rockylinux.org/vault/rocky/9.4/BaseOS/x86_64/os/
repo --name="AppStream" --baseurl=https://dl.rockylinux.org/vault/rocky/9.4/AppStream/x86_64/os/
repo --name="Extras"    --baseurl=https://dl.rockylinux.org/vault/rocky/9.4/extras/x86_64/os/

eula --agreed

# Reboot after installation
reboot

# Do not start the Inital Setup app
firstboot --disable

# System language, keyboard and timezone
lang en_US.UTF-8
keyboard us
timezone UTC --utc

# Set the first NIC to acquire IPv4 address via DHCP
network --device eth0 --bootproto=dhcp

# Disable the firewall completely
firewall --disabled

# Permissive SELinux
selinux --permissive

# Do not set up XX Window System
skipx

# Initial disk setup
# Use the first paravirtualized disk
ignoredisk --only-use=vda
# Bootloader
bootloader --location=mbr --boot-drive=vda
# Wipe invalid partition tables
zerombr
# Erase all partitions and assign default labels
clearpart --all --initlabel
# Initialize the primary root partition with ext4 filesystem
part /boot/efi --fstype=efi --size=512 --ondisk=vda
part /boot --fstype=ext4 --size=1024 --ondisk=vda
part / --size=1 --grow --asprimary --fstype=ext4

# Set root password
rootpw --plaintext password

# Add a user named packer
user --groups=wheel --name=rocky --password=rocky --plaintext --gecos="rocky"

%post --erroronfail

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*
dnf -y install dkms
# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub
sed -i 's/GRUB_ENABLE_BLSCFG=.*/GRUB_ENABLE_BLSCFG=false/g' /etc/default/grub

yum clean all

# Passwordless sudo for the user 'rocky'
echo "rocky ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/rocky
chmod 440 /etc/sudoers.d/rocky

#---- Optional - Install your SSH key ----
# mkdir -m0700 /home/rocky/.ssh/
#
# cat <<EOF >/home/rocky/.ssh/authorized_keys
# ssh-rsa <your_public_key_here> you@your.domain
# EOF
#
### set permissions
# chmod 0600 /home/rocky/.ssh/authorized_keys
#
#### fix up selinux context
# restorecon -R /home/rocky/.ssh/
#
# Move to a writeable directory in the new system

sed -i 's/^#*PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
eject /dev/cdrom || true
%end

%packages
@Core
epel-release
bash-completion
cloud-init
cloud-utils-growpart
rsync
tar
patch
yum-utils
grub2-efi-x64
shim-x64
grub2-efi-x64-modules
efibootmgr
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
openssh-server
curl
wget
selinux-policy
selinux-policy-targeted
policycoreutils
kernel-headers
kernel-devel
kernel-devel-matched
kernel-modules
kernel-modules-core
kernel-modules-extra
-plymouth
# Remove ALSA firmware
-a*-firmware
# Remove Intel wireless firmware
-i*-firmware
%end
