#!/bin/bash -ex
#
# install-custom-kernel.sh - Install custom kernel, if specified
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

if  [ -z  "${CLOUDIMG_CUSTOM_KERNEL}" ]; then
  echo "Not installing custom kernel, since none was specified."
  exit 0
fi

echo "Installing custom kernel ${CLOUDIMG_CUSTOM_KERNEL}"
apt-get install -y ${CLOUDIMG_CUSTOM_KERNEL}

# Record the installed kernel version, so that the curtin hook knows about it.
mkdir -p /curtin
echo -n "${CLOUDIMG_CUSTOM_KERNEL}" > /curtin/CUSTOM_KERNEL
