<?xml version="1.0"?>
<!DOCTYPE profile>
<profile xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns">
    <add-on>
        <add_on_products config:type="list">
            <listentry>
                <media_url>
                    <![CDATA[dvd:///?devices=/dev/sr0]]>
                </media_url>
                <product>sle-module-basesystem-release</product>
                <product_dir>/Module-Basesystem</product_dir>
            </listentry>
            <listentry>
                <media_url>
                    <![CDATA[dvd:///?devices=/dev/sr0]]>
                </media_url>
                <product>sle-module-public-cloud</product>
                <product_dir>/Module-Public-Cloud</product_dir>
            </listentry>
            <listentry>
                <media_url>
                    <![CDATA[dvd:///?devices=/dev/sr0]]>
                </media_url>
                <product>sle-module-server-applications</product>
                <product_dir>/Module-Server-Applications</product_dir>
            </listentry>
            <listentry>
                <media_url>
                    <![CDATA[dvd:///?devices=/dev/sr0]]>
                </media_url>
                <product>sle-module-python3</product>
                <product_dir>/Module-Python3</product_dir>
            </listentry>
        </add_on_products>
    </add-on>
    <bootloader>
        <global>
            <activate>true</activate>
            <append>splash=silent quiet showopts</append>
            <append_failsafe>showopts apm=off noresume edd=off powersaved=off nohz=off highres=off processor.max_cstate=1 nomodeset x11failsafe</append_failsafe>
            <boot_boot>true</boot_boot>
            <boot_extended>false</boot_extended>
            <boot_mbr>true</boot_mbr>
            <boot_root>true</boot_root>
            <default>0</default>
            <distributor>SLES15</distributor>
            <os_prober>false</os_prober>
            <timeout config:type="integer">8</timeout>
        </global>
        <loader_type>grub2-efi</loader_type>
    </bootloader>
    <firewall>
        <enable_firewall config:type="boolean">false</enable_firewall>
        <start_firewall config:type="boolean">false</start_firewall>
    </firewall>
    <general>
        <ask-list config:type="list" />
        <self_update config:type="boolean">false</self_update>
        <mode>
            <halt config:type="boolean">true</halt>
            <confirm config:type="boolean">false</confirm>
            <second_stage config:type="boolean">false</second_stage>
        </mode>
        <proposals config:type="list" />
        <signature-handling>
            <accept_file_without_checksum config:type="boolean">true</accept_file_without_checksum>
            <accept_non_trusted_gpg_key config:type="boolean">true</accept_non_trusted_gpg_key>
            <accept_unknown_gpg_key config:type="boolean">true</accept_unknown_gpg_key>
            <accept_unsigned_file config:type="boolean">true</accept_unsigned_file>
            <accept_verification_failed config:type="boolean">false</accept_verification_failed>
            <import_gpg_key config:type="boolean">true</import_gpg_key>
        </signature-handling>
        <storage />
    </general>
    <login_settings />
    <networking>
        <dhcp_options>
            <dhclient_client_id />
            <dhclient_hostname_option>AUTO</dhclient_hostname_option>
        </dhcp_options>
        <dns>
            <dhcp_hostname config:type="boolean">false</dhcp_hostname>
            <domain>maas.io</domain>
            <hostname>sles</hostname>
            <resolv_conf_policy>auto</resolv_conf_policy>
            <write_hostname config:type="boolean">true</write_hostname>
        </dns>
        <interfaces config:type="list">
            <interface>
                <bootproto>dhcp</bootproto>
                <device>eth0</device>
                <dhclient_set_default_route>yes</dhclient_set_default_route>
                <startmode>auto</startmode>
                <usercontrol>no</usercontrol>
            </interface>
        </interfaces>
        <keep_install_network config:type="boolean">false</keep_install_network>
    </networking>
    <partitioning config:type="list">
        <drive>
            <enable_snapshots config:type="boolean">false</enable_snapshots>
            <initialize config:type="boolean">true</initialize>
            <partitions config:type="list">
                <partition>
                    <create config:type="boolean">true</create>
                    <filesystem config:type="symbol">ext4</filesystem>
                    <format config:type="boolean">true</format>
                    <mount>/</mount>
                    <mountby config:type="symbol">device</mountby>
                    <partition_id config:type="integer">131</partition_id>
                    <partition_nr config:type="integer">1</partition_nr>
                    <resize config:type="boolean">true</resize>
                    <size>max</size>
                </partition>
            </partitions>
            <use>all</use>
        </drive>
    </partitioning>
    <report>
        <errors>
            <log config:type="boolean">true</log>
            <show config:type="boolean">true</show>
            <timeout config:type="integer">0</timeout>
        </errors>
        <messages>
            <log config:type="boolean">true</log>
            <show config:type="boolean">true</show>
            <timeout config:type="integer">0</timeout>
        </messages>
        <warnings>
            <log config:type="boolean">true</log>
            <show config:type="boolean">true</show>
            <timeout config:type="integer">0</timeout>
        </warnings>
        <yesno_messages>
            <log config:type="boolean">true</log>
            <show config:type="boolean">true</show>
            <timeout config:type="integer">0</timeout>
        </yesno_messages>
    </report>
    <services-manager>
        <default_target>multi-user</default_target>
        <services>
            <disable config:type="list" />
            <enable config:type="list">
                <service>sshd</service>
            </enable>
        </services>
    </services-manager>
    <software>
        <products config:type="list">
            <product>SLES</product>
        </products>
        <packages config:type="list">
            <package>bash-completion</package>
            <package>bcache-tools</package>
            <package>btrfsprogs</package>
            <package>bzip2</package>
            <package>cloud-init</package>
            <package>cryptsetup</package>
            <package>gcc</package>
            <package>glibc</package>
            <package>jfsutils</package>
            <package>kernel-default-devel</package>
            <package>kernel-default</package>
            <package>kexec-tools</package>
            <package>lvm2</package>
            <package>make</package>
            <package>mdadm</package>
            <package>openssh</package>
            <package>perl</package>
            <package>python3-configobj</package>
            <package>python3-distro</package>
            <package>python3-Jinja2</package>
            <package>python3-jsonpatch</package>
            <package>python3-jsonschema</package>
            <package>python3-oauthlib</package>
            <package>python3-PrettyTable</package>
            <package>python3-PyYAML</package>
            <package>python3-requests</package>
            <package>sudo</package>
            <package>tar</package>
            <package>wget</package>
            <package>xfsprogs</package>
            ${GRUB_PKGS}
            <package>grub2-branding-SLE</package>
        </packages>
        <patterns config:type="list">
            <pattern>base</pattern>
        </patterns>
        <remove-packages config:type="list">
            <package>adaptec-firmware</package>
            <package>atmel-firmware</package>
            <package>bash-doc</package>
            <package>cifs-utils</package>
            <package>cups-libs</package>
            <package>ipw-firmware</package>
            <package>mpt-firmware</package>
            <package>postfix</package>
            <package>samba-libs</package>
            <package>ucode-intel</package>
            <package>snapper</package>
            <package>snapper-zypp-plugin</package>
        </remove-packages>
    </software>
    <timezone>
        <hwclock>UTC</hwclock>
        <timezone>UTC</timezone>
    </timezone>
    <user_defaults>
        <expire />
        <group>100</group>
        <groups>video,dialout</groups>
        <home>/home</home>
        <inactive>-1</inactive>
        <shell>/bin/bash</shell>
        <skel>/etc/skel</skel>
        <umask>022</umask>
    </user_defaults>
    <users config:type="list">
        <user>
            <encrypted config:type="boolean">false</encrypted>
            <fullname>root</fullname>
            <gid>0</gid>
            <home>/root</home>
            <password_settings>
                <expire />
                <flag />
                <inact />
                <max />
                <min />
                <warn />
            </password_settings>
            <shell>/bin/bash</shell>
            <uid>0</uid>
            <user_password>!</user_password>
            <username>root</username>
        </user>
    </users>
    <scripts>
        <chroot-scripts config:type="list">
            <script>
                <filename>cloud-init.sh</filename>
                <interpreter>shell</interpreter>
                <chrooted config:type="boolean">true</chrooted>
                <source><![CDATA[
#!/bin/sh
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service
]]>
                </source>
            </script>
        </chroot-scripts>
        <init-scripts config:type="list">
            <script>
                <filename>clean-persistent-net.sh</filename>
                <source><![CDATA[
#!/bin/sh
cat< /dev/null > /etc/udev/rules.d/70-persistent-net.rules
sed -i s/^root:[^:]*/root:*/ /etc/shadow
rm -rf /root/.ssh
rm -rf /root/.cache
rm -rf /etc/ssh/ssh_host_*
]]>
                </source>
            </script>
        </init-scripts>
    </scripts>
</profile>
