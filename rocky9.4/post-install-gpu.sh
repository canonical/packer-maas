#!/bin/bash
set -e

if [ "$IMAGE_TYPE" != "gpu" ]; then
  echo "Skipping GPU setup since IMAGE_TYPE is not 'gpu'"
  exit 0
fi

# Actual GPU setup commands

cd /root

curl -JLO -q https://www.mellanox.com/downloads/DOCA/DOCA_v2.10.0/host/doca-host-2.10.0-093000_25.01_rhel95.x86_64.rpm
rpm -i doca-host-2.10.0-093000_25.01_rhel95.x86_64.rpm

dnf clean all
dnf -y install doca-ofed
dnf config-manager --set-enabled crb

dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
dnf install -y nvidia-driver-cuda kmod-nvidia-open-dkms

rm -f /etc/machine-id /var/lib/dbus/machine-id
touch /etc/machine-id
