#!/bin/bash

set -ouex pipefail

# Copy files
rsync -rv /ctx/files/. /

# Install packages
dnf5 copr enable -y atim/starship
dnf5 copr enable -y kylegospo/webapp-manager
dnf5 copr enable -y bieszczaders/kernel-cachyos-addons
dnf5 copr enable -y che/nerd-fonts

dnf5 install -y \
  starship \
  nerd-fonts \
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

# Uninstall Packages
dnf5 remove -y \
  firefox \
  firefox-langpacks \
  power-profiles-daemon

dnf5 -y copr disable atim/starship
dnf5 -y copr disable kylegospo/webapp-manager
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons
dnf5 -y copr disable che/nerd-fonts

dnf5 clean packages

# Fonts
fc-cache -f -v

# Systemd
systemctl enable syncthing@maxim.service
systemctl enable scx_loader.service

# Plymouth
plymouth-set-default-theme catppuccin-mocha
