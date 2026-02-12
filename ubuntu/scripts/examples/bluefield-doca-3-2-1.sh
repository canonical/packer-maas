#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

BASE_URL="https://linux.mellanox.com/public/repo/doca"
GPG_KEY="GPG-KEY-Mellanox.pub"
TMP_GPG="/tmp/${GPG_KEY}"
DPU_ARCH="aarch64"
DOCA_VERSION="3.2.1"
TMP_KEYRING="/tmp/mellanox-keyring.gpg"
MELLANOX_GPG="/etc/apt/keyrings/mellanox.gpg"
KERNEL="6.8.0"
KSUBVER="1013"
KVER_DASH="$KERNEL-$KSUBVER"
KREVISION="17"
BF_KERNEL_VERSION="$KERNEL.$KSUBVER.14"
BSP_VERSION="4.13.1-13827"
BOOTIMAGE_DEB="/tmp/mlxbf-bootimages-signed_${BSP_VERSION}_arm64.deb"

mkdir -p /etc/apt/keyrings
wget -O "$TMP_GPG" "https://linux.mellanox.com/public/repo/doca/$DOCA_VERSION/ubuntu24.04/$DPU_ARCH/$GPG_KEY"
gpg --no-default-keyring --keyring "$TMP_KEYRING" --import "$TMP_GPG"
gpg --no-default-keyring --keyring "$TMP_KEYRING" --export --output "$MELLANOX_GPG"
rm -f "$TMP_KEYRING" "$TMP_GPG"
echo "deb [signed-by=$MELLANOX_GPG] $BASE_URL/$DOCA_VERSION/ubuntu24.04/$DPU_ARCH ./" | tee /etc/apt/sources.list.d/doca.list

wget -O "$BOOTIMAGE_DEB" "${BASE_URL}/${DOCA_VERSION}/ubuntu24.04/${DPU_ARCH}/mlxbf-bootimages-signed_${BSP_VERSION}_arm64.deb"
dpkg -i "$BOOTIMAGE_DEB"
rm -f "$BOOTIMAGE_DEB"

apt-get update
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -f \
    linux-bluefield=$BF_KERNEL_VERSION \
    linux-bluefield-headers-$KVER_DASH=$KVER_DASH.$KREVISION \
    linux-bluefield-tools-$KVER_DASH=$KVER_DASH.$KREVISION \
    linux-buildinfo-$KVER_DASH-bluefield=$KVER_DASH.$KREVISION \
    linux-headers-$KVER_DASH-bluefield=$KVER_DASH.$KREVISION \
    linux-headers-bluefield=$BF_KERNEL_VERSION \
    linux-image-$KVER_DASH-bluefield=$KVER_DASH.$KREVISION \
    linux-image-bluefield=$BF_KERNEL_VERSION \
    linux-modules-$KVER_DASH-bluefield=$KVER_DASH.$KREVISION \
    linux-modules-extra-$KVER_DASH-bluefield=$KVER_DASH.$KREVISION \
    linux-tools-$KVER_DASH-bluefield=$KVER_DASH.$KREVISION \
    linux-tools-bluefield=$BF_KERNEL_VERSION \
    bridge-utils \
    conntrack \
    dmidecode \
    ebtables \
    edac-utils \
    iptables-persistent \
    iputils-arping \
    iputils-ping \
    iputils-tracepath \
    irqbalance \
    jq \
    curl \
    kexec-tools \
    lldpd \
    lm-sensors \
    mstflint \
    net-tools \
    nftables \
    tcpdump \
    vim \
    mlnx-ofed-kernel-modules \
    doca-runtime \
    doca-devel \
    libxlio \
    libxlio-dev \
    libxlio-utils \
    strongswan \
    mlnx-fw-updater-signed

apt-mark hold linux-bluefield linux-headers-bluefield linux-image-bluefield \
    mlnx-ofed-kernel-modules doca-runtime doca-devel mlnx-fw-updater-signed

rm /etc/apt/sources.list.d/doca.list
sed -i -E "s/(_unsigned|_prod|_dev)/_packer_maas/;" /etc/mlnx-release
sed -i -e "s/FORCE_MODE=.*/FORCE_MODE=yes/" /etc/infiniband/openib.conf

systemctl enable NetworkManager.service || true
systemctl enable NetworkManager-wait-online.service || true
systemctl enable acpid.service || true
systemctl enable mlx-openipmi.service || true
systemctl enable mlx_ipmid.service || true
systemctl enable set_emu_param.service || true
systemctl disable openvswitch-ipsec || true
systemctl disable srp_daemon.service || true
systemctl disable ibacm.service || true
systemctl disable opensmd.service || true
systemctl disable unattended-upgrades.service || true
systemctl disable apt-daily-upgrade.timer || true
systemctl disable ModemManager.service || true

# Remove conflicting and unused configurations from bf-release
sed -i \
    -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="text debug console=hvc0 console=ttyAMA0 earlycon=pl011,0x13010000 fixrtc net.ifnames=0 biosdevname=0 iommu.passthrough=1 earlyprintk=efi,keep"/' \
    -e 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=""/' \
    /etc/default/grub
rm /etc/cloud/cloud.cfg.d/91-dib-cloud-init-datasources.cfg
# Let MAAS manage netplan and name the OOB interface
rm /etc/netplan/60-mlnx.yaml
rm /etc/udev/rules.d/92-oob_net.rules
# OVS bridges creation will be managed by MAAS and cloud-init
sed -i 's/CREATE_OVS_BRIDGES="yes"/CREATE_OVS_BRIDGES="no"/' /etc/mellanox/mlnx-ovs.conf
# hw-offload is not applied when CREATE_OVS_BRIDGES="no", so enforce it here
ovs-vsctl --no-wait set Open_vSwitch . other_config:hw-offload=true
# Use Bluefield provided tools to enable DOCA for OVS
sed -i 's/OVS_DOCA="no"/OVS_DOCA="yes"/' /etc/mellanox/mlnx-ovs.conf

mkdir -p /curtin
echo -n "linux-bluefield=$BF_KERNEL_VERSION" > /curtin/CUSTOM_KERNEL
