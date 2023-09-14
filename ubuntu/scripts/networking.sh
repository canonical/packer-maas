#!/bin/bash -ex
#
# networking.sh - Prepare image to boot with cloud-init
#
# Author: Alexsander de Souza <alexsander.souza@canonical.com>
#
# Copyright (C) 2021 Canonical
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
export DEBIAN_FRONTEND=noninteractive

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
