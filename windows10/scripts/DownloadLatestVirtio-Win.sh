#!/bin/bash

# Create iso directory
if ! test -d ../iso;
then
  mkdir -p ../iso
fi

# Download virtio-win.iso
base_url="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/"
latest_version=$(curl -s $base_url | grep -o 'virtio-win-[0-9.]*-[0-9]*/' | sort -Vr | head -n 1)
iso_url="${base_url}${latest_version}virtio-win.iso"

#save the latest iso version to be used as a filename
latest_iso=${latest_version:0:-1}.iso

#check to see if the user already has the latest version avalible
if ! test -f ../iso/$latest_iso;
then
  curl -L -o ../iso/$latest_iso $iso_url
else
  echo "Version ${latest_iso:11:-4} is the latest version. Nothing to download."
fi