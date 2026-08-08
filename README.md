# ammix-os

Locally built Fedora 44 COSMIC Atomic bootc image for the `ammix` workstation. The image owns Fedora packages, fonts, COSMIC, `/etc`, system services, and hardware-neutral policy. User configuration, user Flatpaks, API tokens, and user services live in `ammix/dotfiles`.

This repository does not publish an image. GitHub Actions runs static checks only, and there are no scheduled builds, registry uploads, signatures, disk images, QCOW2 tooling, or VM recipes.

## Local workflow

```text
just fmt
just test
just image-build
```

`just image-build` builds rootfully into `localhost/ammix-os:dev`. Fedora 44 is deliberately selected through the moving `quay.io/fedora-ostree-desktops/cosmic-atomic:44` tag; record the resolved base digest shown by Podman for each build because individual Fedora registry digests expire.

On a future installed Fedora bootc target, rebuild the same tag on that machine and run:

```text
just deploy-local
```

The deploy recipe is host-changing, requires typing the full image reference as confirmation, and stages with:

```text
sudo bootc switch --transport containers-storage localhost/ammix-os:dev
```

It does not request an immediate reboot. Never run it while preparing or validating the backup from the current NixOS host.

For offline recovery only, a locally built image can be exported with Podman to an OCI directory and transported separately. That is not the normal update channel.

## Policy

- Fedora 44 COSMIC Atomic remains the base until an explicit migration changes it.
- Nix and GNU Stow are absent from the future image.
- Chezmoi and age are installed from Fedora repositories.
- System Flatpak applications and system remotes are removed during the image build. User-only Flatpaks are installed explicitly from the dotfiles repository.
- Image updates are manual local rebuilds and switches. There is no `bootc upgrade` timer.
- 1Password and Vivaldi use signature-checked vendor repositories. RPM Fusion release packages and the LACT COPR provide capabilities not available in the Fedora base.
- YubiKey/FIDO/PIV tools are installed, but PAM authentication is not enabled automatically.
- Installer disk layout, EFI, LUKS, filesystems, and machine-specific hardware facts are deferred to installation time.

See `docs/nixos-parity.md`, `docs/package-gaps.md`, and `docs/cutover.md` before switching a machine.
