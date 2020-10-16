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

repo --name="AppStream" --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=AppStream"
repo --name="Extras" --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=extras"

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
cloud-init
# cloud-init only requires python3-oauthlib with MAAS. As such upstream
# removed this dependency.
python3-oauthlib
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
# Remove Intel wireless firmware
-i*-firmware
%end
