<?xml version="1.0"?>
<installation srtype="ext">
    <primary-disk>vda</primary-disk>
    <guest-disk>vda</guest-disk>
    <keymap>us</keymap>
    <root-password>mypassword</root-password>
    <source type="local" />
    <post-install-script type="url">
          http://10.0.2.2:8100/xenserver8.post.sh
    </post-install-script>
    <admin-interface name="eth0" proto="dhcp" />
    <timezone>America/LosAngeles</timezone>
</installation>
 
