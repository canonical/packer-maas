#!/usr/bin/env python

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )

import codecs
import os
import re
import sys

from curtin import (
    block,
    config,
    util,
    )

try:
    from curtin import FEATURES as curtin_features
except ImportError:
    curtin_features = []

write_files = None
try:
    from curtin.futil import write_files
except ImportError:
    pass

centos_apply_network_config = None
try:
    if 'CENTOS_APPLY_NETWORK_CONFIG' in curtin_features:
        from curtin.commands.curthooks import centos_apply_network_config
except ImportError:
    pass

"""
CentOS 6

Currently Support:

- Legacy boot
- DHCP of BOOTIF

Not Supported:

- UEFI boot (*Bad support, most likely wont support)
- Multiple network configration
- IPv6
"""

FSTAB_PREPEND = """\
#
# /etc/fstab
# Created by MAAS fast-path installer.
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
"""

FSTAB_APPEND = """\
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
"""

GRUB_CONF = """\
#
# /boot/grub/grub.conf
# Created by MAAS fast-path installer.
#
default 0
timeout 0
title MAAS
 root {grub_root}
 kernel /boot/{vmlinuz} root=UUID={root_uuid} {extra_opts}
 initrd /boot/{initrd}
"""


def get_block_devices(target):
    """Returns list of block devices for the given target."""
    devs = block.get_devices_for_mp(target)
    blockdevs = set()
    for maybepart in devs:
        (blockdev, part) = block.get_blockdev_for_partition(maybepart)
        blockdevs.add(blockdev)
    return list(blockdevs)


def get_root_info(target):
    """Returns the root partitions information."""
    rootpath = block.get_devices_for_mp(target)[0]
    rootdev = os.path.basename(rootpath)
    blocks = block._lsblock()
    return blocks[rootdev]


def read_file(path):
    """Returns content of a file."""
    with codecs.open(path, encoding='utf-8') as stream:
        return stream.read()


def write_fstab(target, curtin_fstab):
    """Writes the new fstab, using the fstab provided
    from curtin."""
    fstab_path = os.path.join(target, 'etc', 'fstab')
    fstab_data = read_file(curtin_fstab)
    with open(fstab_path, 'w') as stream:
        stream.write(FSTAB_PREPEND)
        stream.write(fstab_data)
        stream.write(FSTAB_APPEND)


def extract_kernel_params(data):
    """Extracts the kernel parametes from the provided
    grub config data."""
    match = re.search('^\s+kernel (.+?)$', data, re.MULTILINE)
    return match.group(0)


def strip_kernel_params(params, strip_params=[]):
    """Removes un-needed kernel parameters."""
    new_params = []
    for param in params:
        remove = False
        for strip in strip_params:
            if param.startswith(strip):
                remove = True
                break
        if remove is False:
            new_params.append(param)
    return new_params


def get_boot_file(target, filename):
    """Return the full filename of file in /boot on target."""
    boot_dir = os.path.join(target, 'boot')
    files = [
        fname
        for fname in os.listdir(boot_dir)
        if fname.startswith(filename)
        ]
    if not files:
        return None
    return files[0]


def write_grub_conf(target, grub_root, extra=[]):
    """Writes a new /boot/grub/grub.conf with the correct
    boot arguments."""
    root_info = get_root_info(target)
    grub_path = os.path.join(target, 'boot', 'grub', 'grub.conf')
    extra_opts = ' '.join(extra)
    vmlinuz = get_boot_file(target, 'vmlinuz')
    initrd = get_boot_file(target, 'initramfs')
    with open(grub_path, 'w') as stream:
        stream.write(
            GRUB_CONF.format(
                grub_root=grub_root,
                vmlinuz=vmlinuz,
                initrd=initrd,
                root_uuid=root_info['UUID'],
                extra_opts=extra_opts) + '\n')


def get_extra_kernel_parameters():
    """Extracts the extra kernel commands from /proc/cmdline
    that should be placed onto the host.

    Any command following the '--' entry should be placed
    onto the host.
    """
    cmdline = read_file('/proc/cmdline')
    cmdline = cmdline.split()
    if '--' not in cmdline:
        return []
    idx = cmdline.index('--') + 1
    if idx >= len(cmdline) + 1:
        return []
    return strip_kernel_params(
        cmdline[idx:],
        strip_params=['initrd=', 'BOOT_IMAGE=', 'BOOTIF='])


def get_grub_root(target):
    """Extracts the grub root (hdX,X) from the grub command.

    This is used so the correct root device is used to install
    stage1/stage2 boot loader.

    Note: grub-install normally does all of this for you, but
    since the grub is older, it has an issue with the ISCSI
    target as /dev/sda and cannot enumarate it with the BIOS.
    """
    with util.RunInChroot(target) as in_chroot:
        data = '\n'.join([
            'find /boot/grub/stage1',
            'quit',
            ]).encode('utf-8')
        out, err = in_chroot(['grub', '--batch'],
                             data=data, capture=True)
        regex = re.search('^\s+(\(.+?\))$', out, re.MULTILINE)
        return regex.groups()[0]


def grub_install(target, root):
    """Installs grub onto the root."""
    root_dev = root.split(',')[0] + ')'
    with util.RunInChroot(target) as in_chroot:
        data = '\n'.join([
            'root %s' % root,
            'setup %s' % root_dev,
            'quit',
            ]).encode('utf-8')
        in_chroot(['grub', '--batch'],
                  data=data)


def set_autorelabel(target):
    """Creates file /.autorelabel.

    This is used by SELinux to relabel all of the
    files on the filesystem to have the correct
    security context. Without this SSH login will
    fail.
    """
    path = os.path.join(target, '.autorelabel')
    open(path, 'a').close()


def get_boot_mac():
    """Return the mac address of the booting interface."""
    cmdline = read_file('/proc/cmdline')
    cmdline = cmdline.split()
    try:
        bootif = [
            option
            for option in cmdline
            if option.startswith('BOOTIF')
            ][0]
    except IndexError:
        return None
    _, mac = bootif.split('=')
    mac = mac.split('-')[1:]
    return ':'.join(mac)


def get_interface_names():
    """Return a dictionary mapping mac addresses to interface names."""
    sys_path = "/sys/class/net"
    ifaces = {}
    for iname in os.listdir(sys_path):
        mac = read_file(os.path.join(sys_path, iname, "address"))
        mac = mac.strip().lower()
        ifaces[mac] = iname
    return ifaces


def get_ipv4_config(iface, data):
    """Returns the contents of the interface file for ipv4."""
    config = [
        'TYPE="Ethernet"',
        'NM_CONTROLLED="no"',
        'USERCTL="yes"',
        ]
    if 'hwaddress' in data:
        config.append('HWADDR="%s"' % data['hwaddress'])
    else:
        # Last ditch effort, use the device name, it probably won't match
        # though!
        config.append('DEVICE="%s"' % iface)
    if data['auto']:
        config.append('ONBOOT="yes"')
    else:
        config.append('ONBOOT="no"')

    method = data['method']
    if method == 'dhcp':
        config.append('BOOTPROTO="dhcp"')
        config.append('PEERDNS="yes"')
        config.append('PERSISTENT_DHCLIENT="1"')
        if 'hostname' in data:
            config.append('DHCP_HOSTNAME="%s"' % data['hostname'])
    elif method == 'static':
        config.append('BOOTPROTO="none"')
        config.append('IPADDR="%s"' % data['address'])
        config.append('NETMASK="%s"' % data['netmask'])
        if 'broadcast' in data:
            config.append('BROADCAST="%s"' % data['broadcast'])
        if 'gateway' in data:
            config.append('GATEWAY="%s"' % data['gateway'])
    elif method == 'manual':
        config.append('BOOTPROTO="none"')
    return '\n'.join(config)


def write_interface_config(target, iface, data):
    """Writes config for interface."""
    family = data['family']
    if family != "inet":
        # Only supporting ipv4 currently
        print(
            "WARN: unsupported family %s, "
            "failed to configure interface: %s" (family, iface))
        return
    config = get_ipv4_config(iface, data)
    path = os.path.join(
        target, 'etc', 'sysconfig', 'network-scripts', 'ifcfg-%s' % iface)
    with open(path, 'w') as stream:
        stream.write(config + '\n')


def write_network_config(target, mac):
    """Write network configuration for the given MAC address."""
    inames = get_interface_names()
    iname = inames[mac.lower()]
    write_interface_config(
        target, iname, {
            'family': 'inet',
            'hwaddress': mac.upper(),
            'auto': True,
            'method': 'dhcp'
        })


def apply_networking(cfg, target, bootmac):
    if 'network' in cfg and centos_apply_network_config:
        centos_apply_network_config(cfg['network'], target)
        return

    if 'network' in cfg:
        sys.stderr.write("WARN: network configuration provided, but "
                         "no support for applying. Using basic config.")
    write_network_config(target, bootmac)


def handle_cloudconfig(cfg, target):
    if not cfg.get('cloudconfig'):
        return
    if not write_files:
        sys.stderr.write(
            "WARN: Unable to handle 'cloudconfig' section in config."
            "No 'write_files' found from curtin.\n")
        return

    base_dir = os.path.join(target, 'etc/cloud/cloud.cfg.d')
    write_files(cfg['cloudconfig'], base_dir)


def main():
    state = util.load_command_environment()
    target = state['target']
    if target is None:
        print("Target was not provided in the environment.")
        sys.exit(1)
    fstab = state['fstab']
    if fstab is None:
        print("/etc/fstab output was not provided in the environment.")
        sys.exit(1)
    bootmac = get_boot_mac()
    if bootmac is None:
        print("Unable to determine boot interface.")
        sys.exit(1)
    devices = get_block_devices(target)
    if not devices:
        print("Unable to find block device for: %s" % target)
        sys.exit(1)

    write_fstab(target, fstab)

    grub_root = get_grub_root(target)
    write_grub_conf(target, grub_root, extra=get_extra_kernel_parameters())
    grub_install(target, grub_root)

    set_autorelabel(target)

    if state.get('config'):
        cfg = config.load_config(state['config'])
    else:
        cfg = {}

    handle_cloudconfig(cfg, target)

    apply_networking(cfg, target, bootmac)


if __name__ == "__main__":
    main()
