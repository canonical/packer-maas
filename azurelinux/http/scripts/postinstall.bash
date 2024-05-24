#!/bin/bash

# Make curtin happy by faking RHEL8 this needs to be fixed in curtin
cp /etc/os-release /etc/os-release.orig
sed -i 's/^ID=.*/ID=redhat/g;s/^VERSION_ID=.*/VERSION_ID="8.0"/g;s/^VERSION=.*/VERSION="8.0"/g;s/^NAME=.*/NAME="Red Hat Enterprise Linux"/g' /etc/os-release
mkdir -p  /etc/rpm/
echo "%rhel 8" | tee -a /etc/rpm/macros.dist

# Add Cloud-Init
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf
yum update
yum install -y cloud-init awk python3-pip xfsprogs

# Missing cloud-init dependencies
pip3 install pyserial
systemctl enable cloud-init

# Clean-up
rm /etc/resolv.conf
exit 0
