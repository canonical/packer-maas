#!/bin/sh

# Reset cloud-init, so that it can run again when MAAS deploy the image.
cloud-init clean --logs

# cloud-init put networking in place on initial boot. Let's remove that, to
# allow MAAS to configure the networking on deploy.
rm -f /etc/netplan/50-cloud-init.yaml
cat< /dev/null > /etc/udev/rules.d/70-persistent-net.rules

# We had to allow root to ssh for the image setup. Let's try to revert that.
sed -i s/^root:[^:]*/root:*/ /etc/shadow
rm -rf /root/.ssh
rm -rf /root/.cache
rm -rf /etc/ssh/ssh_host_*
