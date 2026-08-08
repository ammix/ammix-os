# Cutover checklist

1. Keep the current `mydots` checkout, Nix configuration, SOPS YAML, Stow sources, and age identity backup intact.
2. Build `localhost/ammix-os:dev` rootfully on the future Fedora target and record the resolved Fedora base digest.
3. Confirm the image contains no Nix or Stow package and no `/nix` mount policy.
4. Confirm `flatpak remotes --system` and `flatpak list --system --app` are empty.
5. Restore the age identity out of band with mode `0600`.
6. Apply `ammix/dotfiles`, then run its explicit Flatpak and user-service setup commands.
7. Confirm the installed user belongs to the `libvirt` group before using system virtualization.
8. Test 1Password SSH signing and Vivaldi integration before relying on them.
9. Initialize Waydroid explicitly if it is wanted.
10. Decide EFI, LUKS, filesystem, and disk layout in the installer; do not copy NixOS generated hardware configuration.
11. Keep YubiKey PAM login disabled until a separate recovery-tested enrollment is complete.
12. Inspect `bootc status` and confirm a rollback deployment before rebooting.

`just deploy-local` is the only repository command that changes the booted deployment. It is never part of formatting, tests, or image construction.
