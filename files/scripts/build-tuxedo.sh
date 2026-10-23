#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "1. Compiling Tuxedo Drivers from Source"
echo "=========================================="

# Select the newest kernel development tree available in the build container.
KERNEL_BUILD_DIR=$(
  find /usr/src/kernels -mindepth 1 -maxdepth 1 -type d \
    -exec test -f '{}/Makefile' \; \
    -print | sort -V | tail -n 1
)

if [[ -z "$KERNEL_BUILD_DIR" ]]; then
  echo "ERROR: Could not find a kernel-devel build tree." >&2
  exit 1
fi

KERNEL_VERSION=$(basename "$KERNEL_BUILD_DIR")
echo "Building Tuxedo drivers for kernel $KERNEL_VERSION"

# latest source code from Tuxedo's official development repository
git clone https://gitlab.com/tuxedocomputers/development/packages/tuxedo-drivers.git /tmp/tuxedo-drivers

# Clone the desired commit (hash) or branch (name) source code from Tuxedo's official development repository
#TUXEDO_DRIVERS_REF="a929f9ce143316b3b18d5f3fbf9cc54f0c1122e2"
#git clone \
#  --branch "$TUXEDO_DRIVERS_REF" \
#  --depth 1 \
#  https://gitlab.com/tuxedocomputers/development/packages/tuxedo-drivers.git \
#  /tmp/tuxedo-drivers

cd /tmp/tuxedo-drivers

# Compile the drivers against the selected kernel.
make KDIR="$KERNEL_BUILD_DIR"

# Install the compiled modules manually because modules_install is unavailable in
# the BlueBuild environment.
MODULE_DIR="/usr/lib/modules/$KERNEL_VERSION/extra/tuxedo"
mkdir -p "$MODULE_DIR"

mapfile -t MODULES < <(find . -type f -name '*.ko' -print | sort)
if [[ "${#MODULES[@]}" -eq 0 ]]; then
  echo "ERROR: Driver build produced no kernel modules." >&2
  exit 1
fi

declare -A INSTALLED_MODULES=()
for module in "${MODULES[@]}"; do
  module_name=$(basename "$module")

  if [[ -n "${INSTALLED_MODULES[$module_name]:-}" ]]; then
    echo "ERROR: Duplicate kernel module filename: $module_name" >&2
    exit 1
  fi

  cp "$module" "$MODULE_DIR/$module_name"
  INSTALLED_MODULES["$module_name"]="$module"
done

# Generate module dependency and alias indexes for the selected kernel.
depmod -b /usr "$KERNEL_VERSION"

echo "=========================================="
echo "2. Tuxedo Control Center (TCC) Installation"
echo "=========================================="

# We extract files manually instead of installing the RPM directly.
# This prevents the RPM's post-install scripts (like systemctl daemon-reload) 
# from failing and breaking the offline container build.

mkdir -p /tmp/tcc
cd /tmp/tcc

# Dynamically get the current Fedora/Bazzite major version
FEDORA_VERSION=$(source /etc/os-release && echo $VERSION_ID)
#FEDORA_VERSION=$(rpm -E %fedora)
echo "Found fedora version: $FEDORA_VERSION"

# Fail safe check
if [ -z "$FEDORA_VERSION" ]; then
    echo "ERROR: Could not find FEDORA_VERSION on the server."
    exit 1
fi

# BASE URL for Tuxedo Fedora repository using the dynamic version
BASE_URL="https://rpm.tuxedocomputers.com/fedora/${FEDORA_VERSION}/x86_64/base"

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
