{
  "product": {
    "id": "SLES",
  },
    "root": {
    "password": "!",
  },
  "localization": {
    "language": "en_US.UTF-8"
  },
  "software": {
    "products": ["SLES"],
    "patterns": ["minimal_base"]
  },
  "scripts": {
    "post": [
      {
        name: "finalize.sh",
        chroot: false,
        body: |||
          #!/bin/bash
          export fin_log="/mnt/var/log/finalize.log"
          export baseURL="https://cdn.opensuse.org/download/distribution/leap/16.0/repo/oss/${ARCH}/"
          export ci_pkg=$(curl -s $baseURL | grep -oP '(?<=href="\./)[^"]+\.rpm(?=")' | grep cloud-init | sort | head -n1)
          mount /dev/vda2 /mnt
          for x in dev sys proc run; do mount -v -o bind /$x /mnt/$x; done &>> $fin_log
          mkdir -v /cdrom &>> $fin_log
          mount /dev/sr0 /cdrom &>> $fin_log
          mkdir -pv /mnt/run/initramfs/live/install &>> $fin_log
          mount -o bind /cdrom/install /mnt/run/initramfs/live/install &>> $fin_log
          chroot /mnt /usr/bin/bash -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf" &>> $fin_log
          chroot /mnt zypper install -ny cloud-init &>> $fin_log
          chroot /mnt curl -o /tmp/$ci_pkg -L $baseURL/$ci_pkg &>> $fin_log
          chroot /mnt zypper install -ny /tmp/$ci_pkg &>> $fin_log
          chroot /mnt suseconnect -p PackageHub/16.0/x86_64  &>> $fin_log
          chroot /mnt zypper --non-interactive ref &>> $fin_log
          chroot /mnt zypper --non-interactive --auto-agree-with-licenses update &>> $fin_log
          chroot /mnt zypper --non-interactive cc &>> $fin_log
          chroot /mnt sed -i '/^#/d' /etc/os-release &>> $fin_log
          chroot /mnt rm -v /tmp/$ci_pkg &>> $fin_log
          chroot /mnt systemctl enable cloud-init-local.service &>> $fin_log
          chroot /mnt systemctl enable cloud-init.service &>> $fin_log
          chroot /mnt systemctl enable cloud-config.service &>> $fin_log
          chroot /mnt systemctl enable cloud-final.service &>> $fin_log
          chroot /mnt rm -v /etc/resolv.conf &>> $fin_log
          chroot /mnt /usr/bin/bash -c "cat< /dev/null > /etc/udev/rules.d/70-persistent-net.rules" &>> $fin_log
          chroot /mnt sed -i s/^root:[^:]*/root:*/ /etc/shadow &>> $fin_log
          chroot /mnt rm -rfv /root/.ssh &>> $fin_log
          chroot /mnt rm -rfv /root/.cache &>> $fin_log
          chroot /mnt rm -rf /etc/ssh/ssh_host_* &>> $fin_log
          shutdown 0
        |||,
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

