# ammix-os

Fedora Silverblue bootc image for my desktop. Built on the [official Fedora Silverblue image](https://quay.io/repository/fedora/fedora-silverblue?tab=info).

## Remote workflow

To stage the published update channel on a Fedora bootc system:

```text
sudo bootc switch ghcr.io/ammix/ammix-os:latest
```

## Local workflow

```text
just fix
just format
just check
just lint
just build localhost/ammix-os dev
```

To stage the locally built image:

```text
sudo bootc switch --transport containers-storage localhost/ammix-os:dev
```
