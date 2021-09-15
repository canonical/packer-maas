#!/bin/sh

apt-get install -qy netplan.io cloud-init

cat > /etc/sysctl.d/99-cloudimg-ipv6.conf <<EOF
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0
EOF

rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg
rm -f /etc/cloud/ds-identify.cfg
rm -f /etc/netplan/00-installer-config.yaml

rm -f /var/log/cloud-init*.log
rm -rf /var/lib/cloud/instances \
    /var/lib/cloud/instance
