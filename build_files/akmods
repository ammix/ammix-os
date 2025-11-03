#!/usr/bin/env bash

# build-vbox-kmod.sh

# Tell script to exit on any error
set -eoux pipefail

# Get the exact kernel version that was installed in the build container
KERNEL_VERSION="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)"

echo "Building VirtualBox kmod for Kernel: ${KERNEL_VERSION}"

# Force akmods to build and install the kmod for the target kernel
# This command builds the module and installs it into /usr/lib/modules/
akmods --force --kernels "${KERNEL_VERSION}"

echo "Successfully built and installed VirtualBox kmod."
