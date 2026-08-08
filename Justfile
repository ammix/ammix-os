set shell := ["bash", "-euo", "pipefail", "-c"]

image := "localhost/ammix-os:dev"

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
    @if rg -n '(^|[^[:alnum:]])(nix|stow)([^[:alnum:]]|$)|/nix|bootc upgrade|flatpak update --noninteractive|ghcr\.io/ammix' Containerfile build_files files .github; then \
      echo 'forbidden Nix/Stow, automatic update, or publishing reference detected' >&2; \
      exit 1; \
    fi
    @test ! -e disk_config
    @test ! -e image.toml
    @test ! -e artifacthub-repo.yml
    @test ! -e cosign.pub

image-build:
    sudo podman build --pull=newer --tag {{ image }} .

deploy-local:
    #!/usr/bin/env bash
    set -euo pipefail
    printf 'This changes the booted host. Type "switch localhost/ammix-os:dev" to continue: '
    read -r confirmation
    [[ "$confirmation" == 'switch localhost/ammix-os:dev' ]]
    sudo bootc switch --transport containers-storage {{ image }}
