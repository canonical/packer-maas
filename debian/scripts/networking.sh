#!/bin/bash -ex
#
# networking.sh - Prepare image to boot with cloud-init
#
# Author: Alexsander de Souza <alexsander.souza@canonical.com>
# Author: Alan Baghumian <alan.baghumian@canonical.com>
#
# Copyright (C) 2023 Canonical
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

# Configure apt proxy if needed.
packer_apt_proxy_config="/etc/apt/apt.conf.d/packer-proxy.conf"
if  [ ! -z  "${http_proxy}" ]; then
  echo "Acquire::http::Proxy \"${http_proxy}\";" >> ${packer_apt_proxy_config}
fi
if  [ ! -z  "${https_proxy}" ]; then
  echo "Acquire::https::Proxy \"${https_proxy}\";" >> ${packer_apt_proxy_config}
fi

apt-get install -qy cloud-init netplan.io python3-serial

cat > /etc/sysctl.d/99-cloudimg-ipv6.conf <<EOF
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0
EOF

rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg
rm -f /etc/cloud/ds-identify.cfg

# Install a dpkg-query wrapper to bypass MAAS netplan.io check
cat > /usr/local/bin/dpkg-query <<EOF
#!/bin/sh
[ "\$1" = '-s' ] && [ "\$2" = 'netplan.io' ] && exit 0
/usr/bin/dpkg-query "\$@"
EOF
chmod 755 /usr/local/bin/dpkg-query


# Debian netplan.io does not have an info parameter, work around it
cat > /usr/local/bin/netplan <<EOF
#!/bin/sh
[ "\$1" = 'info' ] && exit 0
/usr/sbin/netplan "\$@"
EOF
chmod 755 /usr/local/bin/netplan


# This is a super dirty trick to make this work. Debian's cloud-init is
# missing MAAS bindings and this causes the installation to fail the 
# last phase after a reboot. This can be upgraded back to Debian's 
# version after the installation has been completed.
# TODO: Figure a way to upstream the changes.

# Bookworm LP#2011454
if [ ${DEBIAN_VERSION} == '12' ]; then
     wget http://archive.ubuntu.com/ubuntu/pool/main/c/cloud-init/cloud-init_23.1.2-0ubuntu0~23.04.1_all.deb
     dpkg -i cloud-init_23.1.2-0ubuntu0~23.04.1_all.deb
     rm cloud-init_23.1.2-0ubuntu0~23.04.1_all.deb
else
    wget http://archive.ubuntu.com/ubuntu/pool/main/c/cloud-init/cloud-init_20.1-10-g71af48df-0ubuntu5_all.deb
    dpkg -i cloud-init_20.1-10-g71af48df-0ubuntu5_all.deb
    rm cloud-init_20.1-10-g71af48df-0ubuntu5_all.deb
fi


# Enable the following lines if willing to use Netplan
#echo 'ENABLED=1' > /etc/default/netplan
#systemctl disable networking; systemctl mask networking
#mv /etc/network/{interfaces,interfaces.save}
#systemctl enable systemd-networkd
