{
  "product": {
    "id": "SLES",
  },
    "root": {
    "password": "!"
  },
  "localization": {
    "language": "en_US.UTF-8"
  },
  "software": {
    "products": ["SLES"],
    "patterns": ["base"]
  },
  "scripts": {
    "post": [
      {
        name: "finalize.sh",
        chroot: false,
        content: "#!/bin/bash\nexport fin_log=\"/mnt/var/log/finalize.log\"; export baseURL=\"https://cdn.opensuse.org/download/distribution/leap/16.0/repo/oss/${ARCH}/\"; export repo_pkg=$(curl -s $baseURL | grep -oP '(?<=href=\"\\./)[^\"]+\\.rpm(?=\")' | grep openSUSE-repos-Leap | sort | head -n1); mount /dev/vda2 /mnt; for x in dev sys proc run; do mount -v -o bind /$x /mnt/$x; done &>> $fin_log; mkdir -v /cdrom &>> $fin_log; mount /dev/sr0 /cdrom &>> $fin_log; mkdir -pv /mnt/run/initramfs/live/install &>> $fin_log; mount -o bind /cdrom/install /mnt/run/initramfs/live/install &>> $fin_log; chroot /mnt /usr/bin/bash -c \"echo 'nameserver 8.8.8.8' > /etc/resolv.conf\" &>> $fin_log; chroot /mnt rpm --import https://download.opensuse.org/distribution/leap/16.0/repo/oss/repodata/repomd.xml.key; chroot /mnt curl -o /tmp/$repo_pkg -L $baseURL/$repo_pkg &>> $fin_log; chroot /mnt zypper install -ny /tmp/$repo_pkg &>> $fin_log; chroot /mnt zypper -n refresh &>> $fin_log; chroot /mnt zypper -n install cloud-init &>> $fin_log; chroot /mnt zypper removerepo -a &>> $fin_log; chroot /mnt sed -i '/^#/d' /etc/os-release &>> $fin_log; chroot /mnt rm -v /tmp/$repo_pkg; chroot /mnt systemctl enable cloud-init-local cloud-init cloud-config cloud-final &>> $fin_log; chroot /mnt /usr/bin/bash -c \"cat < /dev/null > /etc/udev/rules.d/70-persistent-net.rules\" &>> $fin_log; chroot /mnt sed -i s/^root:[^:]*/root:*/ /etc/shadow &>> $fin_log; chroot /mnt rm -rfv /etc/resolv.conf /root/.ssh /root/.cache /etc/ssh/ssh_host_* &>> $fin_log; shutdown 0"
      }
    ]
  },
  "legacyAutoyastStorage": [
    {
      "enable_snapshots": false,
      "initialize": true,
      "partitions": [
        {
          "create": true,
          "filesystem": "ext4",
          "format": true,
          "mount": "/",
          "mountby": "device",
          "partition_id": 131,
          "partition_nr": 1,
          "resize": true,
          "size": "max"
        }
      ],
      "use": "all"
    }
  ]
}

