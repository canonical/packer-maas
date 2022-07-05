url --url="https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/"
url --mirrorlist="http://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=BaseOS-8"
repo --name="AppStream" --mirrorlist="http://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=rocky-AppStream-8.6"
repo --name="Extras" --mirrorlist="http://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=rocky-extras-8.6"

eula --agreed

# Turn off after installation
poweroff

# Do not start the Inital Setup app
firstboot --disable

# System language, keyboard and timezone
lang en_US.UTF-8
keyboard us
timezone UTC --isUtc

# Set the first NIC to acquire IPv4 address via DHCP
network --device eth0 --bootproto=dhcp
# Enable firewal, let SSH through
firewall --enabled --service=ssh
# Enable SELinux with default enforcing policy
selinux --enforcing

# Do not set up XX Window System
skipx

# Initial disk setup
# Use the first paravirtualized disk
ignoredisk --only-use=vda
# Place the bootloader on the Master Boot Record
bootloader --location=mbr --driveorder="vda" --timeout=1
# Wipe invalid partition tables
zerombr
# Erase all partitions and assign default labels
clearpart --all --initlabel
# Initialize the primary root partition with ext4 filesystem
part / --size=1 --grow --asprimary --fstype=ext4

# Set root password
rootpw --plaintext password

# Add a user named packer
user --groups=wheel --name=rocky --password=rocky --plaintext --gecos="rocky"

%post --erroronfail
# workaround anaconda requirements and clear root password
passwd -d root
passwd -l root

# Clean up install config not applicable to deployed environments.
for f in resolv.conf fstab; do
    rm -f /etc/$f
    touch /etc/$f
    chown root:root /etc/$f
    chmod 644 /etc/$f
done

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub

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

%end

%packages
@Core
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
-plymouth
# Remove ALSA firmware
-a*-firmware
# Remove Intel wireless firmware
-i*-firmware
%end
