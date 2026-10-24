#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "1. Compiling Tuxedo Drivers from Source"
echo "=========================================="

# Select the newest kernel development tree available in the build container.
KERNEL_BUILD_DIR=$(
  for directory in /usr/lib/modules/*/build /usr/src/kernels/*; do
    if [[ -f "$directory/Makefile" ]]; then
      printf '%s\n' "$directory"
    fi
  done | sort -V | tail -n 1
)

if [[ -z "$KERNEL_BUILD_DIR" ]]; then
  KERNEL_VERSION=$(
    find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d \
      -printf '%f\n' | sort -V | tail -n 1
  )

  if [[ -z "$KERNEL_VERSION" ]]; then
    echo "ERROR: Could not determine the image kernel version." >&2
    exit 1
  fi

  DNF=$(command -v dnf5 || command -v dnf || true)
  if [[ -z "$DNF" ]]; then
    echo "ERROR: Neither dnf5 nor dnf is available to install kernel-devel." >&2
    exit 1
  fi

  FEDORA_VERSION=$(printf '%s\n' "$KERNEL_VERSION" | sed -nE 's/.*\.fc([0-9]+)\..*/\1/p')
  if [[ -z "$FEDORA_VERSION" ]]; then
    echo "ERROR: Could not determine Fedora release from kernel $KERNEL_VERSION." >&2
    exit 1
  fi

  KERNEL_BUILD_REPO="/etc/yum.repos.d/tuxedo-kernel-build.repo"
  cat > "$KERNEL_BUILD_REPO" <<EOF
[tuxedo-fedora]
name=Fedora ${FEDORA_VERSION} - \$basearch
baseurl=https://dl.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VERSION}/Everything/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=https://src.fedoraproject.org/rpms/fedora-repos/raw/rawhide/f/RPM-GPG-KEY-fedora-${FEDORA_VERSION}-primary

[tuxedo-fedora-updates]
name=Fedora ${FEDORA_VERSION} - \$basearch - Updates
baseurl=https://dl.fedoraproject.org/pub/fedora/linux/updates/${FEDORA_VERSION}/Everything/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://src.fedoraproject.org/rpms/fedora-repos/raw/rawhide/f/RPM-GPG-KEY-fedora-${FEDORA_VERSION}-primary
EOF

  if ! "$DNF" -y install "kernel-devel-$KERNEL_VERSION"; then
    KERNEL_NEVR="${KERNEL_VERSION%.*}"
    KERNEL_ARCH="${KERNEL_VERSION##*.}"
    KERNEL_VERSION_RELEASE="${KERNEL_NEVR#*-}"
    KERNEL_VERSION_NUMBER="${KERNEL_NEVR%%-*}"
    KOJI_URL="https://kojipkgs.fedoraproject.org/packages/kernel/${KERNEL_VERSION_NUMBER}/${KERNEL_VERSION_RELEASE}/${KERNEL_ARCH}/kernel-devel-${KERNEL_VERSION_NUMBER}-${KERNEL_VERSION_RELEASE}.${KERNEL_ARCH}.rpm"

    echo "Exact kernel-devel package was not available in enabled repos; downloading:"
    echo "$KOJI_URL"
    curl --fail --location --retry 3 --retry-all-errors "$KOJI_URL" -o /tmp/kernel-devel.rpm
    "$DNF" -y install bison flex /tmp/kernel-devel.rpm
    rm -f /tmp/kernel-devel.rpm
  fi

  KERNEL_BUILD_DIR="/usr/lib/modules/$KERNEL_VERSION/build"
  if [[ ! -f "$KERNEL_BUILD_DIR/Makefile" ]]; then
    KERNEL_BUILD_DIR="/usr/src/kernels/$KERNEL_VERSION"
  fi
  rm -f "$KERNEL_BUILD_REPO"
fi

if [[ ! -f "$KERNEL_BUILD_DIR/Makefile" ]]; then
  echo "ERROR: Could not find a kernel-devel build tree for $KERNEL_VERSION." >&2
  exit 1
fi

if [[ "$(basename "$KERNEL_BUILD_DIR")" == "build" ]]; then
  KERNEL_VERSION=$(basename "$(dirname "$KERNEL_BUILD_DIR")")
else
  KERNEL_VERSION=$(basename "$KERNEL_BUILD_DIR")
fi
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

# Resolve the Fedora major version without assuming VERSION_ID is a Fedora
# release number; Utah uses a date-based VERSION_ID.
FEDORA_VERSION=$(
  rpm -E %fedora 2>/dev/null |
    grep -m1 -E '^[0-9]+$' ||
    rpm -qa --qf '%{RELEASE}\n' 2>/dev/null |
      grep -oE 'fc[0-9]+' |
      sed 's/^fc//' |
      sort -n | tail -n 1
)
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
curl -fL "$BASE_URL/$LATEST_RPM" -o tcc.rpm

# Extract the RPM package
rpm2cpio tcc.rpm | cpio -idmv

# Distribute the extracted files into the actual system directories
# We use 'if [ -d ... ]' to check if the directory actually exists in the RPM 
# before trying to copy it. This prevents the script from crashing.

if [ -d "opt/tuxedo-control-center" ]; then
    cp -r opt/tuxedo-control-center /opt/
fi

TCC_SERVICE_DIR="opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/dist-data"
if [[ -d "$TCC_SERVICE_DIR" ]]; then
    while IFS= read -r service_file; do
        service_name=$(basename "$service_file")
        ln -sfn "/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/dist-data/$service_name" \
            "/usr/lib/systemd/system/$service_name"
    done < <(find "$TCC_SERVICE_DIR" -type f -name '*.service' -print)
fi

if [ -d "usr/bin" ]; then
    cp -r usr/bin/* /usr/bin/
fi

if [ -d "usr/lib/systemd/system" ]; then
    cp -r usr/lib/systemd/system/* /usr/lib/systemd/system/
fi

# Keep the recipe's stable service name compatible with TCC package versions.
SERVICE_UNIT=""
for candidate in \
    /usr/lib/systemd/system/tccd.service \
    /usr/lib/systemd/system/tuxedo-control-center.service \
    /usr/lib/systemd/system/tuxedo-control-center*.service; do
    if [[ -f "$candidate" ]]; then
        SERVICE_UNIT="$candidate"
        break
    fi
done

if [[ -z "$SERVICE_UNIT" ]]; then
    echo "ERROR: Tuxedo Control Center systemd unit was not found in the RPM." >&2
    exit 1
fi

if [[ "$(basename "$SERVICE_UNIT")" != "tccd.service" ]]; then
    ln -sf "$(basename "$SERVICE_UNIT")" /usr/lib/systemd/system/tccd.service
fi

if [ -d "usr/share" ]; then
    cp -r usr/share/* /usr/share/
fi

if [ -d "etc" ]; then
    cp -r etc/* /etc/
fi
