url ${KS_OS_REPOS} ${KS_PROXY}
repo --name="AppStream" ${KS_APPSTREAM_REPOS} ${KS_PROXY}
repo --name="Extras" ${KS_EXTRAS_REPOS} ${KS_PROXY}

eula --agreed

# Turn off after installation
poweroff

firstboot --disable

lang en_US.UTF-8
keyboard us
timezone UTC --utc

network --device eth0 --bootproto=dhcp
firewall --enabled --service=ssh
selinux --enforcing

skipx

ignoredisk --only-use=vda
bootloader --disabled
zerombr
clearpart --all --initlabel
part / --size=1 --grow --asprimary --fstype=ext4

rootpw --plaintext password

user --groups=wheel --name=rocky --password=rocky --plaintext --gecos="rocky"

%post --erroronfail

systemctl enable sshd
systemctl start sshd

# Clear root password (lock access)
passwd -d root
passwd -l root

# Clean up default config
for f in resolv.conf fstab; do
    rm -f /etc/$f
    touch /etc/$f
    chown root:root /etc/$f
    chmod 644 /etc/$f
done

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

# Fix GRUB for serial console output
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub
sed -i 's/GRUB_ENABLE_BLSCFG=.*/GRUB_ENABLE_BLSCFG=false/g' /etc/default/grub

yum clean all

# Passwordless sudo for the rocky user
echo "rocky ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/rocky
chmod 440 /etc/sudoers.d/rocky

# Enable cloud-init data sources for Metal³ / Ironic
cat > /etc/cloud/cloud.cfg.d/90-metal3.cfg <<EOF
datasource_list: [ NoCloud, ConfigDrive ]
EOF

# Ensure cloud-init is enabled
systemctl enable cloud-init
systemctl enable cloud-config
systemctl enable cloud-final

# Optional: Install your SSH key
# mkdir -m0700 /home/rocky/.ssh/
# echo "ssh-rsa AAAA..." > /home/rocky/.ssh/authorized_keys
# chmod 0600 /home/rocky/.ssh/authorized_keys
# restorecon -R /home/rocky/.ssh/

# 💡 Install dkms in %post to avoid installer dependency resolution issues
dnf install -y dkms

%end

%packages
@Core
openssh-server
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
gcc
make
kernel-devel
kernel-headers
# Exclude unneeded firmware
-plymouth
-a*-firmware
-i*-firmware
%end

