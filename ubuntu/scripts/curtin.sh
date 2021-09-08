#!/bin/sh

apt-get install -y jq
mkdir -p /curtin

mv /tmp/curtin-hooks /curtin/curtin-hooks
chmod 755 /curtin/curtin-hooks
