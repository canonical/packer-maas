#!/bin/bash

# Clean up install config not applicable to deployed environments.
for f in resolv.conf fstab; do
    sudo rm -f /etc/$f
    sudo touch /etc/$f
    sudo chown root:root /etc/$f
    sudo chmod 644 /etc/$f
done

sudo rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

if [ "$SSH_USER_CLEANUP" = "true" ]; then
    sudo userdel -r $SSH_USERNAME
fi
