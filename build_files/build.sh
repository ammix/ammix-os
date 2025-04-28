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
# Create directories
mkdir -p /usr/share/fonts/nerd-fonts/FiraCode
mkdir -p /usr/share/fonts/nerd-fonts/SymbolsOnly
mkdir -p /usr/share/fonts/VictorMono

curl -fLo /tmp/SymbolsOnly.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip
unzip /tmp/SymbolsOnly.zip -d /usr/share/fonts/nerd-fonts/SymbolsOnly/
rm /tmp/SymbolsOnly.zip

curl -fLo /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
unzip /tmp/FiraCode.zip -d /usr/share/fonts/nerd-fonts/FiraCode/
rm /tmp/FiraCode.zip

curl -fLo /tmp/VictorMono_v1.5.6.zip https://rubjo.github.io/victor-mono/VictorMonoAll.zip
unzip -o /tmp/VictorMono_v1.5.6.zip -d /tmp/
mv /tmp/victor-mono-1.5.6/otf/* /usr/share/fonts/VictorMono/
rm /tmp/VictorMono_v1.5.6.zip
rm -rf /tmp/victor-mono-1.5.6/

fc-cache -f -v

# Systemd
systemctl enable podman.socket
systemctl enable syncthing@maxim.service
systemctl enable scx_loader.service

# Plymouth
plymouth-set-default-theme catppuccin-mocha
dracut --force --regenerate-all

# Cleanup
rm -rf /tmp/*
