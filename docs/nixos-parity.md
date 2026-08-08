# NixOS capability parity

This inventory cross-checks the active `mydots` NixOS and Home Manager profiles against the Fedora bootc ownership boundary.

| Capability | Disposition | Implementation |
| --- | --- | --- |
| COSMIC desktop and greeter | Present in Fedora base | Fedora 44 COSMIC Atomic base image. |
| NetworkManager | Present in Fedora base | Fedora Atomic desktop networking. |
| PipeWire and rtkit | Present in Fedora base | Fedora desktop audio stack. |
| Firmware and AMD GPU userspace | Installed by the image | Firmware, Vulkan, VA-API, and camera packages. |
| AMD overdrive policy | Configured by the image | `amdgpu.ppfeaturemask=0xfffd7fff` bootc kernel argument. |
| ntsync | Configured by the image | `/etc/modules-load.d/ntsync.conf`. |
| Plymouth | Configured by the image | Vendored Catppuccin theme selected during build. |
| zram | Present in Fedora base | Fedora Atomic defaults retain zram-generator policy. |
| `de-us` console keymap | Configured by the image | bootc kernel arguments. |
| earlyoom | Installed and configured by the image | Package plus enabled service. |
| fwupd | Installed and configured by the image | Package plus refresh timer. |
| GVFS | Installed by the image | FUSE, SMB, NFS, MTP integrations. |
| LACT | Installed and configured by the image | Signed COPR package plus enabled daemon. |
| SCX LAVD performance mode | Installed and configured by the image | Terra `scx-scheds`, retained performance policy, and enabled loader. |
| gamemode | Installed by the image | Fedora package. |
| usbmuxd and libimobiledevice | Installed and configured by the image | Packages plus enabled service. |
| Podman and Docker CLI compatibility | Installed and configured by the image | Podman packages and socket. |
| Distrobox | Installed by the image | Fedora package. |
| libvirt, virt-manager, and swtpm | Installed and configured by the image | Virtualization group and enabled libvirtd. |
| Waydroid | Installed by the image | Fedora package; container initialization remains explicit. |
| pcscd | Installed and configured by the image | pcsc-lite and enabled socket. |
| YubiKey, FIDO, and PIV tools | Installed by the image | Tooling only; PAM activation is deferred to avoid lockout. |
| 1Password and Vivaldi integration | Installed and configured by the image | Signature-checked repositories and browser allow-list. |
| Controller udev policy | Configured by the image | Tracked `2dc8` hidraw rule. |
| Fedora development groups | Installed by the image | C development, development libraries, and development tools groups. |
| Multimedia codecs | Installed by the image | RPM Fusion multimedia group with weak dependencies and the PackageKit GStreamer plugin excluded. |
| System and development CLI packages | Installed by the image | `build_files/packages.list`; unresolved mappings are recorded separately. |
| Fonts and font cache locations | Installed by the image | Fedora owns packages and cache paths. |
| Shells, terminals, editors, Git, SSH, qutebrowser, Yazi | Managed by Chezmoi | `ammix/dotfiles` reproduces the effective user configuration. |
| MPD | Managed by Chezmoi | Portable config and user unit; explicit enablement. |
| Flatpak applications and overrides | Managed by Chezmoi | User-only, Flathub-only, explicit install. |
| Codex, OpenCode, Context7, and managed skills | Managed by Chezmoi | Ordinary config locations; no Fedora `mcp-nixos`. |
| API tokens | Managed by Chezmoi | Native age ciphertext; identity restored out of band. |
| SearXNG and Redis | Unavailable in current Fedora repositories | Preserved as an explicit package/service gap. |
| NixOS update helpers and nix-direnv | Intentionally omitted | `mydots` remains the rollback source. |
| EFI, LUKS, filesystem, and disk policy | Deferred as hardware/installer policy | Must be chosen during installation. |
| YubiKey PAM login | Deferred as hardware/installer policy | Tooling is present; activation requires a separate lockout-safe procedure. |
