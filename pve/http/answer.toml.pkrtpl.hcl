[global]
keyboard = "de"
country = "de"
fqdn = "pveauto.testinstall"
mailto = "mail@no.invalid"
timezone = "Europe/Berlin"
root-password = "${ssh_password}"

[network]
source = "from-dhcp"

[disk-setup]
filesystem = "ext4"
lvm.swapsize = 0
lvm.maxvz = 0
disk-list = ["vda"]
