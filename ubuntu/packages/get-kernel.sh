#!/bin/sh
#
# get-kernel - Downloads Ubuntu kernel packages
#
# Author: Alexsander de Souza <alexsander.souza@canonical.com>
#
# Copyright (C) 2022 Canonical
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
export LANG=C

KERNEL=${KERNEL:-linux-image-generic}
ARCH=amd64

PACKAGES=$(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends \
  --option APT::Architectures="${ARCH}" \
  ${KERNEL} | grep "^\w" | grep -v -f pkg_filter.list )

apt-get download -o Dir::Cache="./" -o Dir::Cache::archives="./" ${PACKAGES}
