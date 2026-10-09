#!/bin/bash -ex
#
# cloud-img-setup-curtin.sh - Set up curtin curthooks, if needed.
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

if  [[ ! -f  "/curtin/CUSTOM_KERNEL" ]]; then
  echo "Skipping curtin setup, since no custom kernel is used."
  exit 0
fi

echo "Configuring curtin to install custom kernel"

mkdir -p /curtin

FILENAME=curtin-hooks
mv "/tmp/${FILENAME}" /curtin/
chmod 750 "/curtin/${FILENAME}"
