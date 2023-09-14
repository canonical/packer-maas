#!/bin/bash -ex
#
# curtin.sh - Move curtin scripts to final destination
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

apt-get install -y jq
mkdir -p /curtin

# install scripts
for s in curtin-hooks install-custom-packages setup-bootloader; do
  if [ -f "/tmp/$s" ]; then
    mv "/tmp/$s" /curtin/
    chmod 750 "/curtin/$s"
  fi
done

# copy custom packages
if [ -f /tmp/custom-packages.tar.gz ]; then
  mv /tmp/custom-packages.tar.gz /curtin/
fi
