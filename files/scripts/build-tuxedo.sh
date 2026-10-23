#!/bin/bash
set -oue pipefail

echo "=========================================="
echo "1. Compiling Tuxedo Drivers from Source"
echo "=========================================="

# Detect the current kernel version inside the Bazzite image
KERNEL_VERSION=$(ls /usr/lib/modules | grep -v '.*-.*-.*-.*' | head -n 1)

# Clone the latest source code from Tuxedo's official development repository
git clone https://gitlab.com/tuxedocomputers/development/packages/tuxedo-drivers.git /tmp/tuxedo-drivers
cd /tmp/tuxedo-drivers

# Compile the drivers against the current Bazzite kernel
make KDIR=/usr/src/kernels/$KERNEL_VERSION

# Install the compiled modules to the system path
#make KDIR=/usr/src/kernels/$KERNEL_VERSION INSTALL_MOD_PATH=/usr modules_install
# Update kernel module dependencies
#depmod -a -b /usr $KERNEL_VERSION

# INSTALLATION FIX:
# Instead of relying on Tuxedo's Makefile install targets which fail in offline builds,
# we manually create the module directory and copy all compiled .ko files directly into it.
MODULE_DIR="/usr/lib/modules/$KERNEL_VERSION/extra/tuxedo"
mkdir -p $MODULE_DIR
find . -name "*.ko" -exec cp {} $MODULE_DIR/ \;

# Update kernel module dependencies so the system recognizes the new drivers
depmod -a -b /usr $KERNEL_VERSION

echo "=========================================="
echo "2. Tuxedo Control Center (TCC) Installation"
echo "=========================================="

# We extract files manually instead of installing the RPM directly.
# This prevents the RPM's post-install scripts (like systemctl daemon-reload) 
# from failing and breaking the offline container build.

mkdir -p /tmp/tcc
cd /tmp/tcc

# BASE URL for Tuxedo Fedora 44 repository
BASE_URL="https://rpm.tuxedocomputers.com/fedora/44/x86_64/base"

# Dynamically scrape the directory index, sort versions, and get the latest RPM filename
LATEST_RPM=$(curl -s "$BASE_URL/" | grep -o 'href="tuxedo-control-center[^"]*\.rpm"' | cut -d'"' -f2 | sort -V | tail -n 1)

# Fail safe check
if [ -z "$LATEST_RPM" ]; then
    echo "ERROR: Could not find tuxedo-control-center RPM on the server."
    exit 1
fi

echo "Found latest version: $LATEST_RPM"
wget "$BASE_URL/$LATEST_RPM" -O tcc.rpm

# Extract the RPM package
rpm2cpio tcc.rpm | cpio -idmv

# Distribute the extracted files into the actual system directories
# We use 'if [ -d ... ]' to check if the directory actually exists in the RPM 
# before trying to copy it. This prevents the script from crashing.

if [ -d "opt/tuxedo-control-center" ]; then
    cp -r opt/tuxedo-control-center /opt/
fi

if [ -d "usr/bin" ]; then
    cp -r usr/bin/* /usr/bin/
fi

if [ -d "usr/lib/systemd/system" ]; then
    cp -r usr/lib/systemd/system/* /usr/lib/systemd/system/
fi

if [ -d "usr/share" ]; then
    cp -r usr/share/* /usr/share/
fi

if [ -d "etc" ]; then
    cp -r etc/* /etc/
fi
