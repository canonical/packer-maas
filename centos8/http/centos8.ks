url --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=BaseOS"
poweroff
firewall --enabled --service=ssh
firstboot --disable
ignoredisk --only-use=vda
lang en_US.UTF-8
keyboard us
network --device eth0 --bootproto=dhcp
firewall --enabled --service=ssh
selinux --enforcing
timezone UTC --isUtc
bootloader --location=mbr --driveorder="vda" --timeout=1
rootpw --plaintext password

repo --name "AppStream" --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=AppStream"
repo --name "Extras" --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=Extras"
repo --name "cloud-init" --baseurl="http://copr-be.cloud.fedoraproject.org/results/@cloud-init/el-stable/epel-8-x86_64"

zerombr
clearpart --all --initlabel
part / --size=1 --grow --asprimary --fstype=ext4

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

dnf clean all
%end

%packages
@core
bash-completion
cloud-init-el-release
cloud-init
# cloud-init only requires python3-oauthlib with MAAS. As such upstream
# removed this dependency.
python3-oauthlib
linux-firmware
rsync
tar
grub2-efi-x64
efibootmgr
shim-x64
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-plymouth
-iwl6050-firmware
-iwl5000-firmware
-iwl2030-firmware
-iwl1000-firmware
-iwl7260-firmware
-iwl6000g2a-firmware
-iwl5150-firmware
-iwl4965-firmware
-iwl3160-firmware
-iwl2000-firmware
-iwl105-firmware
-iwl100-firmware
-iwl6000-firmware
-iwl3945-firmware
-iwl135-firmware
%end
