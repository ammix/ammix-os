#!/usr/bin/env bash
set -euo pipefail

install -d -m 1777 /var/tmp
dnf5 -y install dnf5 dnf5-plugins rsync
rsync -rlK /ctx/files/ /
chmod 0755 /etc/1password/custom_allowed_browsers

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 copr enable -y ilyaz/LACT
dnf5 config-manager addrepo \
	--from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo
dnf5 -y install terra-release
dnf5 -y install terra-release-extras
dnf5 -y install terra-release-mesa
dnf5 -y config-manager setopt \
	terra.priority=80 \
	terra-extras.priority=80 \
	terra-mesa.priority=80

fedora_version=$(rpm -E %fedora)
dnf5 -y install \
	"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
	"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"
dnf5 -y config-manager setopt \
	rpmfusion-free.priority=90 \
	rpmfusion-free-updates.priority=90 \
	rpmfusion-nonfree.priority=90 \
	rpmfusion-nonfree-updates.priority=90

rpm --import https://downloads.1password.com/linux/keys/1password.asc
rpm --import https://repo.vivaldi.com/archive/linux_signing_key.pub
rpm --import https://repo.cider.sh/RPM-GPG-KEY

dnf5 makecache
# shellcheck source=packages.list
source /ctx/packages.list

dnf5 -y swap ffmpeg-free ffmpeg --allowerasing

dnf5 -y install "${CLI_PACKAGES[@]}"
dnf5 -y install "${CORE_PACKAGES[@]}"
dnf5 -y install "${MEDIA_PACKAGES[@]}"
dnf5 -y install "${GRAPHICAL_APPS[@]}"
dnf5 -y install "${DEVELOPMENT_PACKAGES[@]}"
dnf5 -y install "${FONT_PACKAGES[@]}"
dnf5 -y install "${FIRMWARE_PACKAGES[@]}"
dnf5 -y install 1password 1password-cli vivaldi-stable

for rpm_url in "${EXTERNAL_RPMS[@]}"; do
	dnf5 -y install "$rpm_url"
done

for group in "${DNF_GROUPS[@]}"; do
	dnf5 -y group install --skip-unavailable "$group"
done

dnf5 -y group install --skip-unavailable multimedia \
	--setopt=install_weak_deps=False \
	--exclude=PackageKit-gstreamer-plugin

dnf5 -y remove "${REMOVE_PACKAGES[@]}"

glib-compile-schemas --strict /usr/share/glib-2.0/schemas

systemctl enable \
	ammix-bootc-update.timer \
	earlyoom.service \
	fwupd-refresh.timer \
	lactd.service \
	libvirtd.service \
	pcscd.socket \
	podman.socket \
	scx_loader.service \
	usbmuxd.service

plymouth-set-default-theme catppuccin-mocha
