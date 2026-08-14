# Ammix image-template merge policy

## Merge priorities

- Focus upstream review on build behavior: `Containerfile`, `.github/workflows/build.yml`, `Justfile`, rechunking, and build scripts.
- Keep the root `Justfile` exactly equal to `template/main:Justfile`. This is the primary strategy for reducing future conflicts.
- Keep the concise Ammix README instead of template onboarding documentation. Update commands when upstream recipe names change.
- Keep disk/VM workflows and `disk_config` deleted unless the user explicitly restores that product scope.
- Keep upstream's disk/VM recipes inside the byte-identical Justfile, but do not invoke them or restore their missing configuration.

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
- Preserve current Ammix registry/signing behavior and deliberately newer action pins when they remain compatible.
- The workflow should call upstream Just recipes for name selection, build, rechunking, tag generation, tagging, push, and signing.
- Keep rpm-ostree rechunking active. The image-template currently treats Chunkah as an optional experimental alternative; Ammix chose `ostree-rechunk` for lower build-time and disk risk.

## Conflict defaults that still require confirmation

| Conflict | Recommended resolution |
| --- | --- |
| `Justfile` | Take upstream verbatim and configure via `image-template.env`. |
| `Containerfile` | Keep Ammix build/base logic; manually review upstream build mechanics such as `/opt`. |
| `build.yml` | Start from upstream; reapply only documented Ammix schedule, registry, signing, and pin choices. |
| `README.md` | Keep Ammix documentation and update valid commands. |
| `build-disk.yml` | Keep deleted while disk/ISO builds are unsupported. |
| Template `build_files/build.sh` | Keep Ammix's script content and split stages; do not install sample packages. |
| `system_files/` | Keep absent while the Containerfile and build scripts consume `files/`. |

Always present actual conflicts to the user even when this table provides a recommendation.
