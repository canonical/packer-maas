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

# Reset cloud-init, so that it can run again when MAAS deploy the image.
cloud-init clean --logs

apt-get update
if [ ${BOOT_MODE} == "uefi" ] && [ ${DEBIAN_VERSION} == '12' ]; then
        apt-get install -y grub-cloud-amd64 grub-efi-amd64
else
        apt-get install -y grub-cloud-amd64 grub-pc
fi

# Bookworm does not include this, but curtin requires this during the installation.
if [ ${DEBIAN_VERSION} == '12' ]; then
        wget http://ftp.us.debian.org/debian/pool/main/e/efibootmgr/efibootmgr_15-1_amd64.deb
        dpkg -i efibootmgr_15-1_amd64.deb
        rm efibootmgr_15-1_amd64.deb
fi
