url --url="http://mirror.centos.org/centos/6/os/x86_64"
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

repo --name="Updates" --mirrorlist="http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=updates"
repo --name="Extras" --mirrorlist="http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=extras"
repo --name="EPEL6" --mirrorlist="https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=x86_64"
# CentOS 6 requires a newer version of cloud-init to use advanced features with MAAS.
repo --name="cloud-init" --baseurl="http://copr-be.cloud.fedoraproject.org/results/@cloud-init/el-stable/epel-6-x86_64"

zerombr
clearpart --all --initlabel
part / --size=1 --grow --asprimary --fstype=ext4

%post --erroronfai
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

yum clean all

%end

%packages
@core
chrony
bash-completion
btrfs-progs
cloud-init-el-release
cloud-init
cloud-utils-growpart
# EPEL is needed for updated cloud-init
epel-release
kernel-firmware
rsync
tar
yum-presto
yum-utils
# bridge-utils is required by cloud-init to configure networking. Without it
# installed cloud-init will try to install it itself which will not work in
# isolated environments.
bridge-utils
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
xfsprogs
# Remove unneeded packages
-*alsa*
-abrt*
-at
-authconfig
-b43*
-bind*
-biosdevname
-blktrace
-ConsoleKit*
-centos-indexhtml
-cpuspeed
-crda
-cryptsetup-luks*
-ed
-eggdbus
-eject
-*firmware*
-*fprintd*
-hal*
-hunspell*
-iw
-ledmon
-libX11*
-lsof
-mailx
-mtr
-nano
-ntp*
-pcmciautils
-perl*
-pinfo
-plymouth
-pm-utils
-psacct
-quota
-rdate
-rfkill
-satyr
-scl-utils
-setuptool
-sgpio
-smartmontools
-sos
-strace
-sysstat
-system-config-network-tui
-tcpdump
-tcsh
-usbutils
-wireless-tools
%end
