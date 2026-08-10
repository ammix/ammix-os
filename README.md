# ammix-os

Fedora 44 COSMIC Atomic bootc image for the `ammix` workstation, published as `ghcr.io/ammix/ammix-os:latest`.

## Remote workflow

To stage the published update channel on a Fedora bootc system:

```text
just switch-ghcr
```

The recipe runs:

```text
sudo bootc switch ghcr.io/ammix/ammix-os:latest
```

The enabled `ammix-bootc-update.timer` checks for a new image daily at 13:00 UTC with up to one hour of randomized delay. Scheduled image publication occurs every third calendar day, so checks without a new digest are no-ops. Updates are staged without rebooting automatically.

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
just switch-local
```

The recipe runs:

```text
sudo bootc switch --transport containers-storage localhost/ammix-os:dev
```

Both switch recipes change the host deployment and do not request an immediate reboot. A local switch follows the containers-storage image rather than GHCR; run `just switch-ghcr` to return to the published update channel.

For offline recovery, a locally built image can be exported with Podman to an OCI directory and transported separately.
