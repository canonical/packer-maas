#
# Copyright 2015 Cloudbase Solutions SRL
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import os
import sys
import tempfile
import yaml
import platform
import json

from curtin.log import LOG
from curtin import util
try:
    from curtin.util import load_command_config
except ImportError:
    from curtin.config import load_command_config

CLOUDBASE_INIT_TEMPLATE = """
metadata_services=cloudbaseinit.metadata.services.maasservice.MaaSHttpService
maas_metadata_url={url}
maas_oauth_consumer_key={consumer_key}
maas_oauth_consumer_secret=''
maas_oauth_token_key={token_key}
maas_oauth_token_secret={token_secret}
""" 

CHANGE_LICENSE_TPL = """
slmgr /ipk {license_key}
"""

def get_oauth_data(state):
    cfg = state.get("debconf_selections")
    if not cfg:
        return None
    maas = cfg.get("maas")
    if not maas:
        return None
    data = {i.split(None, 3)[1].split("/")[1]: i.split(None, 3)[-1] for i in maas.split("\n") if len(i) > 0}
    oauth_data = data.get("maas-metadata-credentials")
    metadata_url = data.get("maas-metadata-url")
    if oauth_data is None or metadata_url is None:
        return None
    oauth_dict = {k.split("=")[0].split("_",1)[1]: k.split("=")[1] for k in oauth_data.split("&")}
    oauth_dict["url"] = metadata_url
    return oauth_dict

def get_cloudbaseinit_dir(target):
    dirs = [
        os.path.join(
            target,
            "Cloudbase-Init",
        ),
        os.path.join(
            target,
            "Program Files",
            "Cloudbase Solutions",
            "Cloudbase-Init",
        ),
        os.path.join(
            target,
            "Program Files (x86)",
            "Cloudbase Solutions",
            "Cloudbase-Init",
        ),
    ]
    for i in dirs:
        if os.path.isdir(i):
            return i
    raise ValueError("Failed to find cloudbase-init install destination")

def curthooks():
    state = util.load_command_environment()
    config = load_command_config({}, state)
    target = state['target']
    cloudbaseinit = get_cloudbaseinit_dir(target)

    if target is None:
        sys.stderr.write("Unable to find target.  "
                         "Use --target or set TARGET_MOUNT_POINT\n")
        sys.exit(2)

    context = get_oauth_data(config)
    local_scripts = os.path.join(
        cloudbaseinit,
        "LocalScripts",
    )

    networking = config.get("network")
    if networking:
        curtin_dir = os.path.join(target, "curtin")
        networking_file = os.path.join(target, "network.json")
        if os.path.isdir(curtin_dir):
            networking_file = os.path.join(curtin_dir, "network.json")
        with open(networking_file, "wb") as fd:
            fd.write(json.dumps(networking, indent=2).encode('utf-8'))

    license_key = config.get("license_key")
    if license_key and len(license_key) > 0:
        try:
            license_script = CHANGE_LICENSE_TPL.format({"license_key": license_key})
            os.makedirs(local_scripts)
            licensekey_path = os.path.join(local_scripts, "ChangeLicenseKey.ps1")
            with open(licensekey_path, "w") as script:
                script.write(license_script)
        except Exception as err:
            sys.stderr.write("Failed to write LocalScripts: %r", err)
    cloudbase_init_cfg = os.path.join(
        cloudbaseinit,
        "conf",
        "cloudbase-init.conf")
    cloudbase_init_unattended_cfg = os.path.join(
        cloudbaseinit,
        "conf",
        "cloudbase-init-unattend.conf")

    if os.path.isfile(cloudbase_init_cfg) is False:
        sys.stderr.write("Unable to find cloudbase-init.cfg.\n")
        sys.exit(2)

    cloudbase_init_values = CLOUDBASE_INIT_TEMPLATE.format(**context) 

    fp = open(cloudbase_init_cfg, 'a')
    fp_u = open(cloudbase_init_unattended_cfg, 'a')
    for i in cloudbase_init_values.splitlines():
        fp.write("%s\r\n" % i)
        fp_u.write("%s\r\n" % i)
    fp.close()
    fp_u.close()


curthooks()
