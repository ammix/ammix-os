# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Fedora bootc-based container image using the Cosmic Desktop Environment. The project builds customized bootable container images that can be rebased onto existing atomic Fedora installations or converted to bootable disk images (QCOW2, RAW).

## Build System Architecture

### Container Build Flow

The build process uses a multi-stage Containerfile:
1. **Context stage**: Copies `build_files/` and `files/` into the image
2. **Base stage**: Starts from `quay.io/fedora-ostree-desktops/cosmic-atomic:43`
3. **Build stage**: Executes scripts from `build_files/` in order:
   - `build`: Installs packages, configures repos (RPM Fusion, Terra, COPR), copies files from `files/`
   - `kargs`: Configures kernel arguments via bootc
   - `build-initramfs`: Rebuilds initramfs
   - `finalize`: Cleans up and commits the ostree container
4. **Lint stage**: Validates the bootable container with `bootc container lint`

### Package Management

Package lists are defined in `build_files/packages.list` as bash arrays:
- `CLI_PACKAGES`: CLI utilities (fish, vim, jq, distrobox, etc.)
- `CORE_PACKAGES`: Development and system tools (BPF tools, podman, virtualization, etc.)
- `MEDIA_PACKAGES`: Media codecs and graphics tools
- `GRAPHICAL_APPS`: GUI applications (ghostty, kitty, qutebrowser, Cider)
- `FONT_PACKAGES`: Font collections
- `EXTERNAL_RPMS`: URLs to external RPM files
- `DNF_GROUPS`: DNF group installs
- `REMOVE_PACKAGES`: Packages to remove from base image

### Build-time Files

- `build_files/`: Scripts executed during container build (mounted read-only)
- `files/`: Runtime files copied into the image at `/` (systemd units, configs, plymouth themes, etc.)

## Common Commands

### Building Container Images

```bash
# Build the container image locally
just build

# Build with custom image name and tag
just build <target_image> <tag>
```

### Building Bootable Images

Use Bootc Image Builder (BIB) to convert container images to bootable formats:

```bash
# Build QCOW2 VM image (default)
just build-qcow2

# Build RAW VM image
just build-raw

# Rebuild (podman build + BIB)
just rebuild-qcow2  # or rebuild-raw
```

Output is placed in `output/<type>/` directory.

### Running Virtual Machines

```bash
# Run VM from QCOW2 (opens browser to web console)
just run-vm-qcow2

# Run VM from RAW
just run-vm-raw

# Run with systemd-vmspawn
just spawn-vm rebuild="0" type="qcow2" ram="6G"
```

### Validation

```bash
# Check Justfile syntax
just check

# Auto-fix Justfile formatting
just fix

# Lint shell scripts
just lint

# Format shell scripts
just format
```

### Cleanup

```bash
# Remove build artifacts
just clean
```

## Key Implementation Details

### Bootc Integration

- This is a bootable container image built on Fedora bootc
- The `/opt` directory is made immutable (not symlinked to `/var/opt`) to prevent package data loss during bootc upgrades
- Kernel arguments are configured via `/usr/lib/bootc/kargs.d/ammix-kargs.toml`
- `/nix` mountpoint is prepared for Nix package manager support

### Image Signing

The CI workflow uses cosign to sign published images. The public key is in `cosign.pub`.

### Systemd Services

Custom systemd units in `files/etc/systemd/system/`:
- `ammix-bootc-update.{service,timer}`: Automated bootc updates
- `flatpak-update.{service,timer}`: Automated Flatpak updates

Enabled services include: scx_loader, lactd, libvirtd, podman.socket
Masked services include: grub-boot-success.timer, rpm-ostreed-automatic

### Repository Configuration

The build script configures multiple package sources:
- RPM Fusion (free, nonfree, tainted for firmware)
- Terra repositories (Fyra Labs)
- COPR repos (ilyaz/LACT for AMD GPU control)
- Cider repository for the Cider music player

### Development Notes

- Files must be tracked by git for Nix/bootc builds to see them
- The Justfile uses `just sudoif` wrapper for operations requiring root privileges
- Container images are transferred between rootless and rootful podman using `podman image scp` when needed for BIB builds
