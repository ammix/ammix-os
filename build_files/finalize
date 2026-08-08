#!/usr/bin/bash

set -euo pipefail

dnf5 clean all
find /var/* -maxdepth 0 -type d \! -name cache \! -name log -exec rm -rf {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 -exec rm -rf {} \;
install -d -m 1777 /var/tmp

ostree container commit
