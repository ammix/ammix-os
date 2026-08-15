# Ammix image-template merge policy

## Merge priorities

- Focus upstream review on build behavior: `Containerfile`, `.github/workflows/build.yml`, `Justfile`, rechunking, and build scripts.
- Keep the root `Justfile` exactly equal to `template/main:Justfile`. This is the primary strategy for reducing future conflicts.
- Keep the concise Ammix README instead of template onboarding documentation. Update commands when upstream recipe names change.
- Keep disk/VM workflows and configuration absent unless the user restores that product scope. The byte-identical Justfile may retain unused disk/VM recipes.

## Ammix configuration

Keep image-specific values in `image-template.env`:

```dotenv
IMAGE_NAME=ammix-os
REPO_ORGANIZATION=ammix
IMAGE_DESC="Fedora 44 COSMIC Atomic bootc image for the ammix workstation"
IMAGE_KEYWORDS="bootc,oci,fedora,cosmic"
IMAGE_LOGO_URL="https://github.com/ammix.png"
DEFAULT_TAG=latest
BIB_IMAGE="quay.io/centos-bootc/bootc-image-builder:latest"
```

The upstream Justfile evaluates every declared `env_var`, including `BIB_IMAGE`, even when disk recipes are not used.

## Containerfile and payload

- Keep the Fedora COSMIC Atomic base and Ammix's `BASE_IMAGE`/`FEDORA_VERSION` arguments. Do not replace it with the template's example Bazzite base.
- Keep the active conditional `/opt` workaround. Vivaldi and Filen install under `/opt`; Fedora's `/opt -> /var/opt` layout would otherwise omit their payload from deployments.
- Keep `files/` and the local split build pipeline. Do not adopt the template's empty `system_files/` example.
- Preserve the executable script names `build.sh`, `build-initramfs.sh`, `kargs.sh`, and `finalize.sh`. Update all Containerfile and validation references together if upstream changes their interface.
- The template sample `build.sh` is not a replacement for Ammix's package, initramfs, kernel-argument, and finalization stages.
- Keep `RUN bootc container lint` as the final Containerfile instruction.

## Build workflow

- Use upstream `.github/workflows/build.yml` as the baseline and keep deviations small and explicit.
- Preserve Ammix's every-third-day schedule unless the user changes it.
- Preserve Ammix's registry and signing behavior. Retain an action-pin deviation only while it remains newer than upstream and compatible.
- The workflow should call upstream Just recipes for name selection, build, rechunking, tag generation, tagging, push, and signing.
- Apply execution-mode changes across build, rechunk, tag, and push as a unit so every step uses the same Podman storage.
- Keep rpm-ostree rechunking active unless the user explicitly chooses another upstream rechunker. Ask before changing it when the upstream default changes.
