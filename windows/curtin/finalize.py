#!/usr/bin/env python

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )
from curtin import util
import os
import sys
import json


CLOUDBASE_INIT_CONFIG = """\
metadata_services=cloudbaseinit.metadata.services.maasservice.MaaSHttpService
maas_metadata_url={url}
maas_oauth_consumer_key={consumer_key}
maas_oauth_consumer_secret=''
maas_oauth_token_key={token_key}
maas_oauth_token_secret={token_secret}
"""


LICENSE_KEY_SCRIPT = """\
slmgr /ipk {license_key}
Remove-Item $MyInvocation.InvocationName
"""


def load_config(path):
    """Loads the curtin config."""
    with open(path, 'r') as stream:
        return json.load(stream)


def get_maas_debconf_selections(config):
    """Gets the debconf selections from the curtin config."""
    try:
        return config['debconf_selections']['maas']
    except KeyError:
        return None


def extract_maas_parameters(config):
    """Extracts the needed values from the debconf
    entry."""
    params = {}
    for line in config.splitlines():
        cloud, key, type, value = line.split()[:4]
        if key == "cloud-init/maas-metadata-url":
            params['url'] = value
        elif key == "cloud-init/maas-metadata-credentials":
            values = value.split("&")
            for oauth in values:
                key, value = oauth.split('=')
                if key == 'oauth_token_key':
                    params['token_key'] = value
                elif key == 'oauth_token_secret':
                    params['token_secret'] = value
                elif key == 'oauth_consumer_key':
                    params['consumer_key'] = value
    return params


def get_cloudbase_init_config(params):
    """Returns the cloudbase-init config file."""
    config = CLOUDBASE_INIT_CONFIG.format(**params)
    output = ""
    for line in config.splitlines():
        output += "%s\r\n" % line
    return output


def write_cloudbase_init(target, params):
    """Writes the configuration files for cloudbase-init."""
    cloudbase_init_cfg = os.path.join(
        target,
        "Program Files",
        "Cloudbase Solutions",
        "Cloudbase-Init",
        "conf",
        "cloudbase-init.conf")
    cloudbase_init_unattended_cfg = os.path.join(
        target,
        "Program Files",
        "Cloudbase Solutions",
        "Cloudbase-Init",
        "conf",
        "cloudbase-init-unattend.conf")

    config = get_cloudbase_init_config(params)
    with open(cloudbase_init_cfg, 'a') as stream:
        stream.write(config)
    with open(cloudbase_init_unattended_cfg, 'a') as stream:
        stream.write(config)


def get_license_key(config):
    """Return license_key from the curtin config."""
    try:
        license_key = config['license_key']
    except KeyError:
        return None
    if license_key is None:
        return None
    license_key = license_key.strip()
    if license_key == '':
        return None
    return license_key


def write_license_key_script(target, license_key):
    local_scripts_path = os.path.join(
        target,
        "Program Files",
        "Cloudbase Solutions",
        "Cloudbase-Init",
        "LocalScripts")
    script_path = os.path.join(local_scripts_path, 'set_license_key.ps1')
    set_key_script = LICENSE_KEY_SCRIPT.format(license_key=license_key)
    with open(script_path, 'w') as stream:
        for line in set_key_script.splitlines():
            stream.write("%s\r\n" % line)


def write_network_config(target, config):
    network_config_path = os.path.join(target, 'network.json')
    config_json = config.get('network', None)
    if config_json is not None:
        config_json = json.dumps(config_json)
        with open(network_config_path, 'w') as stream:
            for line in config_json.splitlines():
                stream.write("%s\r\n" % line)


def main():
    state = util.load_command_environment()
    target = state['target']
    if target is None:
        print("Target was not provided in the environment.")
        sys.exit(1)
    config_f = state['config']
    if config_f is None:
        print("Config was not provided in the environment.")
        sys.exit(1)
    config = load_config(config_f)

    debconf = get_maas_debconf_selections(config)
    if debconf is None:
        print("Failed to get the debconf_selections.")
        sys.exit(1)

    params = extract_maas_parameters(debconf)
    write_cloudbase_init(target, params)
    write_network_config(target, config)

    license_key = get_license_key(config)
    if license_key is not None:
        write_license_key_script(target, license_key)


if __name__ == "__main__":
    main()
