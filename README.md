# ammix-os

Fedora 44 COSMIC Atomic bootc image for the `ammix` workstation. The image owns Fedora packages, fonts, COSMIC, `/etc`, system services, and hardware-neutral policy. User configuration, user Flatpaks, API tokens, and user services live in `ammix/dotfiles`.

GitHub Actions builds the image with rootful Podman, rechunks it with rpm-ostree for smaller delta updates, publishes it to `ghcr.io/ammix/ammix-os`, and signs the published digest. The workflow runs for changes to `main`, manual dispatches, pull requests without publishing, and a scheduled build every second calendar day. Static checks remain a separate workflow.

Disk images, QCOW2, raw/ISO, VM recipes, ArtifactHub publication, and hosted build artifacts are intentionally absent.

## Remote workflow

To stage the published update channel on a Fedora bootc system:

```text
just deploy-ghcr
```

The recipe requires typing the full image reference and runs:

```text
sudo bootc switch ghcr.io/ammix/ammix-os:latest
```

The enabled `ammix-bootc-update.timer` checks for a new image daily at 13:00 UTC with up to one hour of randomized delay. Scheduled image publication occurs every second calendar day, so checks without a new digest are no-ops. Updates are staged without rebooting automatically.

Published digests are signed by the GitHub workflow with the existing `SIGNING_SECRET`. The corresponding public key is `cosign.pub`.

## Local workflow

```text
just fmt
just test
just image-build
```

`just image-build` builds rootfully into `localhost/ammix-os:dev`. Fedora 44 is deliberately selected through the moving `quay.io/fedora-ostree-desktops/cosmic-atomic:44` tag; record the resolved base digest shown by Podman for each build because individual Fedora registry digests expire.

To stage the locally built image:

```text
just deploy-local
```

The recipe requires typing the full local image reference and runs:

```text
sudo bootc switch --transport containers-storage localhost/ammix-os:dev
```

Both deploy recipes are host-changing and do not request an immediate reboot. A local deployment follows the containers-storage image rather than GHCR; run `just deploy-ghcr` to return to the published update channel.

For offline recovery, a locally built image can be exported with Podman to an OCI directory and transported separately.

## Policy

- Fedora 44 COSMIC Atomic remains the base until explicitly changed.
- Nix and GNU Stow are absent from the image.
- Chezmoi and age are installed from Fedora repositories.
- System Flatpak applications and system remotes are removed during the image build. User-only Flatpaks are installed explicitly from the dotfiles repository.
- GHCR is the normal update channel; rootful local builds and containers-storage deployment remain supported.
- Vivaldi and Filen require an immutable `/opt`, so the image replaces Fedora's `/opt` symlink before installing packages.
- 1Password, Vivaldi, and Cider use their vendor repositories and keys. Filen is installed from its official rolling desktop RPM URL.
- YubiKey/FIDO/PIV tools are installed, but PAM authentication is not enabled automatically.
- Installer disk layout, EFI, LUKS, filesystems, and machine-specific hardware facts remain installer policy.
