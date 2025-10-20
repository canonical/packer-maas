#!/bin/bash -ex
#
# setup-boot.sh - Set up the image after initial boot
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

ARCH=$(dpkg --print-architecture)

apt-get update
apt-get -y install lvm2 xfsprogs
