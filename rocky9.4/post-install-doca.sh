#!/bin/bash
cd /root

curl -JLO -q https://www.mellanox.com/downloads/DOCA/DOCA_v2.10.0/host/doca-host-2.10.0-093000_25.01_rhel95.x86_64.rpm
rpm -i doca-host-2.10.0-093000_25.01_rhel95.x86_64.rpm

dnf clean all
dnf -y install doca-ofed
dnf config-manager --set-enabled crb

rm -f /etc/machine-id /var/lib/dbus/machine-id
touch /etc/machine-id
