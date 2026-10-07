#!/bin/bash
# Save the real OS identity before modifying /etc/os-release.
. /etc/os-release
AZL_ID="${ID}"
AZL_VERSION="${VERSION_ID}"
ARCH="$(uname -m)"

echo "Detected OS: ${AZL_ID} ${AZL_VERSION} (${ARCH})"

# Temporary DNS for package installation.
cp -L /etc/resolv.conf /tmp/resolv.conf.orig || true
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Select package manager.
if command -v tdnf >/dev/null 2>&1; then
    PKG=tdnf
elif command -v yum >/dev/null 2>&1; then
    PKG=yum
else
    echo "ERROR: neither tdnf nor yum found"
    exit 1
fi

# Ensure the correct Microsoft online repo exists.
case "${AZL_ID}:${AZL_VERSION}" in
    mariner:2.0)
        echo "Configuring CBL-Mariner 2.0"

        if ! grep -Rqs 'packages.microsoft.com/cbl-mariner' /etc/yum.repos.d/ 2>/dev/null; then
            mkdir -p /etc/yum.repos.d

            cat >/etc/yum.repos.d/mariner-official-base.repo <<EOF
[mariner-official-base]
name=CBL-Mariner Official Base 2.0 ${ARCH}
baseurl=https://packages.microsoft.com/cbl-mariner/2.0/prod/base/${ARCH}
gpgkey=file:///etc/pki/rpm-gpg/MICROSOFT-RPM-GPG-KEY file:///etc/pki/rpm-gpg/MICROSOFT-METADATA-GPG-KEY
gpgcheck=1
repo_gpgcheck=1
enabled=1
skip_if_unavailable=False
sslverify=1
EOF
        fi

        ${PKG} clean all
        ${PKG} makecache
        ${PKG} install -y cloud-init awk python3-pip xfsprogs

        # Workaround for Mariner 2.
        pip3 install pyserial
        ;;

    azurelinux:3.0)
        echo "Configuring Azure Linux 3.0"

        if ! grep -Rqs 'packages.microsoft.com/azurelinux' /etc/yum.repos.d/ 2>/dev/null; then
            mkdir -p /etc/yum.repos.d

            cat >/etc/yum.repos.d/azurelinux-official-base.repo <<EOF
[azurelinux-official-base]
name=Azure Linux Official Base 3.0 ${ARCH}
baseurl=https://packages.microsoft.com/azurelinux/3.0/prod/base/${ARCH}
gpgkey=file:///etc/pki/rpm-gpg/MICROSOFT-RPM-GPG-KEY
gpgcheck=1
repo_gpgcheck=1
enabled=1
skip_if_unavailable=False
sslverify=1
EOF
        fi

        ${PKG} clean all
        ${PKG} makecache
        ${PKG} install -y cloud-init
        ;;

    *)
        echo "ERROR: unsupported OS: ${AZL_ID} ${AZL_VERSION}"
        exit 1
        ;;
esac

# Enable cloud-init.
systemctl enable cloud-init.service

# Restore DNS configuration.
if [ -f /tmp/resolv.conf.orig ]; then
    cat /tmp/resolv.conf.orig > /etc/resolv.conf
    rm -f /tmp/resolv.conf.orig
fi

# Make curtin happy. Do this AFTER package installation so we don't
# interfere with repository $releasever detection.
cp /etc/os-release /etc/os-release.orig

sed -i \
    's/^ID=.*/ID=redhat/g;
     s/^VERSION_ID=.*/VERSION_ID="8.0"/g;
     s/^VERSION=.*/VERSION="8.0"/g;
     s/^NAME=.*/NAME="Red Hat Enterprise Linux"/g' \
    /etc/os-release

mkdir -p /etc/rpm
grep -qxF '%rhel 8' /etc/rpm/macros.dist 2>/dev/null ||
    echo '%rhel 8' >> /etc/rpm/macros.dist

shutdown -h now
exit 0
