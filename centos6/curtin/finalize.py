#!/usr/bin/env python

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )

import json
import os
import sys

from curtin import util


DATASOURCE_LIST = """\
datasource_list: [ MAAS ]
"""

DATASOURCE = """\
datasource:
  MAAS: {{consumer_key: {consumer_key}, metadata_url: '{url}',
    token_key: {token_key}, token_secret: {token_secret}}}
"""


def get_datasource(**kwargs):
    """Returns the format cloud-init datasource."""
    return DATASOURCE_LIST + DATASOURCE.format(**kwargs)


def load_config(path):
    """Loads the curtin config."""
    with open(path, 'r') as stream:
        return json.load(stream)


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


def get_maas_debconf_selections(config):
    """Gets the debconf selections from the curtin config."""
    try:
        return config['debconf_selections']['maas']
    except KeyError:
        return None


def write_datasource(target, data):
    """Writes the cloudinit config into
    /etc/cloud/cloud.cfg.d/90_datasource.cfg."""
    path = os.path.join(
        target, 'etc', 'cloud', 'cloud.cfg.d', '90_datasource.cfg')
    with open(path, 'w') as stream:
        stream.write(data + '\n')


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
    datasource = get_datasource(**params)
    write_datasource(target, datasource)


if __name__ == "__main__":
    main()
