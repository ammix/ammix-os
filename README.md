# ammix-os

Fedora COSMIC Atomic bootc image for the my workstation.

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
