#cdrom
harddrive --partition=vdb --dir=/
poweroff
eula --agreed
firewall --enabled --service=ssh
firstboot --disable
lang en_US.UTF-8
keyboard us
network --device eth0 --bootproto=dhcp
firewall --enabled --service=ssh
selinux --enforcing
timezone UTC --utc
rootpw --plaintext password

ignoredisk --only-use=vda
bootloader --disabled
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

# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub
sed -i 's/GRUB_ENABLE_BLSCFG=.*/GRUB_ENABLE_BLSCFG=false/g' /etc/default/grub

# Fix curtin ID_LIKE
echo 'ID_LIKE="rhel centos fedora"' >> /etc/os-release

# Fix curtin boot loader installation
cp -r /boot/efi/EFI/openEuler /boot/efi/EFI/redhat

# Add openeuler to group sudo
usermod -a -G sudo openeuler

# BEGIN cloud-init 25.1 MAAS OAuth callback workaround
# Upstream fix: https://github.com/canonical/cloud-init/commit/9311e066f1eafea68fc714183173d8a5cc197d73
# Only patch installed cloud-init VERSION=25.1, regardless of RPM release.
CLOUD_INIT_VERSION=$(rpm -q --qf '%%{VERSION}' cloud-init) || exit 1
echo "Installed cloud-init version: $CLOUD_INIT_VERSION"
if [ "$CLOUD_INIT_VERSION" = "25.1" ]; then
    CLOUD_INIT_DIR=/usr/lib/python3.11/site-packages
    CLOUD_INIT_PATCH=/tmp/cloud-init-oauth-fix.diff
    if ! command -v patch >/dev/null 2>&1; then
        echo "ERROR: patch utility is unavailable" >&2
        exit 1
    fi

    # Embed the upstream diff; no internet access is needed inside the installer.
    cat > "$CLOUD_INIT_PATCH" <<'CLOUD_INIT_PATCH_EOF'
${CLOUD_INIT_OAUTH_PATCH}
CLOUD_INIT_PATCH_EOF

    if patch --batch --forward --reverse --dry-run -p1 -d "$CLOUD_INIT_DIR" -i "$CLOUD_INIT_PATCH" >/dev/null 2>&1; then
        echo "cloud-init OAuth callback fix already present; skipping"
    elif patch --batch --forward --dry-run -p1 -d "$CLOUD_INIT_DIR" -i "$CLOUD_INIT_PATCH"; then
        echo "Applying cloud-init OAuth callback fix"
        patch --batch --forward -p1 -d "$CLOUD_INIT_DIR" -i "$CLOUD_INIT_PATCH" || exit 1
    else
        echo "ERROR: cloud-init is 25.1, but the OAuth patch does not apply" >&2
        exit 1
    fi

    python3 -m py_compile "$CLOUD_INIT_DIR/cloudinit/url_helper.py" || exit 1
    rm -f "$CLOUD_INIT_PATCH"
else
    echo "cloud-init is not 25.1; skipping OAuth patch"
fi
# END cloud-init 25.1 MAAS OAuth callback workaround

dnf clean all
%end

%packages --ignoremissing
@core
bash-completion
cloud-init
# cloud-init only requires python3-oauthlib with MAAS. As such upstream
# removed this dependency.
python3-oauthlib
patch
rsync
tar
# grub2-efi-x64 ships grub signed for UEFI secure boot. If grub2-efi-x64-modules
# is installed grub will be generated on deployment and unsigned which breaks
# UEFI secure boot.
grub2-pc
grub2-efi-*
shim-*
grub2-efi-*-modules
efibootmgr
dosfstools
lvm2
mdadm
nc
nmap-ncat
device-mapper-multipath
iscsi-initiator-utils
-plymouth
# Remove Intel wireless firmware
-i*-firmware
%end
