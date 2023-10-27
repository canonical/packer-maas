#!/bin/sh -x

TMP_DIR=$(mktemp -d /tmp/packer-maas-XXXX)
MOUNTPOINT=$TMP_DIR/p2

echo 'Mounting partition...'
mkdir -p $MOUNTPOINT
sudo modprobe nbd
sudo qemu-nbd --connect=/dev/nbd0 output-windows_server-2022/packer-windows_server-2022
sudo mount /dev/nbd0p2 $MOUNTPOINT

echo 'Adding curtin-hooks to image...'
mkdir -p $MOUNTPOINT/curtin
cp windows-curtin-hooks/curtin $MOUNTPOINT
sync -f $MOUNTPOINT/curtin

echo 'Adding cloudbase to image...'
mkdir -p $MOUNTPOINT/'Program Files'/'Cloudbase Solutions'/Cloudbase-Init
cp -r ./cloudbase-init/* $MOUNTPOINT/'Program Files'/'Cloudbase Solutions'/Cloudbase-Init/
sync -f $MOUNTPOINT/'Program Files'

echo 'Unmounting image...'
sync -f "$MOUNTPOINT"
umount $MOUNTPOINT
qemu-nbd --disconnect /dev/nbd0
rmmod nbd

echo 'Done'
