# Move to a writeable directory in the new system
cd /root

# Download the RPM
curl -JLO -q https://www.mellanox.com/downloads/DOCA/DOCA_v2.10.0/host/doca-host-2.10.0-093000_25.01_rhel94.x86_64.rpm 

# Install the RPM
echo "Installing Doca Host RPM"
rpm -i doca-host-2.10.0-093000_25.01_rhel94.x86_64.rpm

# Clean DNF cache
dnf clean all
# Install doca-ofed
echo "Installing doca-ofed"
dnf -y --exclude=kernel* install doca-ofed
rm doca-host-2.10.0-093000_25.01_rhel94.x86_64.rpm

# Enable crb
echo "Enabling crb"
dnf config-manager --set-enabled crb

# Install Nvidia Drivers and CUDA
echo "Adding Nvidia Repo"
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
echo "Install CUDA and dkms kernel drivers"
dnf install -y nvidia-driver-cuda kmod-nvidia-open-dkms

# Remove machine-id and related file if it exists
rm -f /etc/machine-id
rm -f /var/lib/dbus/machine-id
# Recreate an empty file so systemd knows to generate a new ID on boot
touch /etc/machine-id
