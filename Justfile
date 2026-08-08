set shell := ["bash", "-euo", "pipefail", "-c"]

image := "localhost/ammix-os:dev"
remote_image := "ghcr.io/ammix/ammix-os:latest"

default:
    @just --list

fmt:
    shfmt -w build_files/*
    just --fmt --unstable

test:
    just --fmt --check
    shfmt -d build_files/*
    shellcheck -x -P build_files build_files/build build_files/build-initramfs build_files/finalize build_files/kargs
    @test "$(tail -n 1 Containerfile)" = "RUN bootc container lint"
    @test "$(rg -c '^FROM \$\{BASE_IMAGE\}:\$\{FEDORA_VERSION\}$' Containerfile)" = "1"
    @if rg -n '(^|[^[:alnum:]])(nix|stow)([^[:alnum:]]|$)|/nix|flatpak update --noninteractive' Containerfile build_files files .github; then \
      echo 'forbidden Nix/Stow or system Flatpak update reference detected' >&2; \
      exit 1; \
    fi
    @test -e .github/workflows/build.yml
    @test -e cosign.pub
    @test ! -e disk_config
    @test ! -e image.toml
    @test ! -e artifacthub-repo.yml

image-build:
    sudo podman build --pull=newer --tag {{ image }} .

deploy-local:
    #!/usr/bin/env bash
    set -euo pipefail
    printf 'This changes the booted host. Type "switch localhost/ammix-os:dev" to continue: '
    read -r confirmation
    [[ "$confirmation" == 'switch localhost/ammix-os:dev' ]]
    sudo bootc switch --transport containers-storage {{ image }}

deploy-ghcr:
    #!/usr/bin/env bash
    set -euo pipefail
    printf 'This changes the booted host. Type "switch ghcr.io/ammix/ammix-os:latest" to continue: '
    read -r confirmation
    [[ "$confirmation" == 'switch ghcr.io/ammix/ammix-os:latest' ]]
    sudo bootc switch {{ remote_image }}
