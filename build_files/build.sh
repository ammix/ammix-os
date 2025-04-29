#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 copr enable -y atim/starship
dnf5 copr enable -y kylegospo/webapp-manager
dnf5 copr enable -y bieszczaders/kernel-cachyos-addons

dnf5 install -y \
  starship \
  webapp-manager \
  scx-scheds \
  syncthing \
  stow \
  fzf \
  ugrep \
  fastfetch \
  kitty \
  steam-devices \
  gamemode \
  gum \
  zathura \
  zathura-fish-completion \
  zathura-plugins-all \
  wqy-zenhei-fonts \
  google-roboto-fonts \
  rsms-inter-fonts \
  mozilla-fira-sans-fonts

dnf5 remove -y firefox firefox-langpacks


dnf5 -y copr disable atim/starship
dnf5 -y copr disable kylegospo/webapp-manager
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

## Fonts
fc-cache -f -v

# Systemd
systemctl enable podman.socket
systemctl enable syncthing@maxim.service
systemctl enable scx_loader.service

# Plymouth
plymouth-set-default-theme catppuccin-mocha

# Cleanup
rm -rf /tmp/*
