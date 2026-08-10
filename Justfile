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
    @if rg -n '(^|[^[:alnum:]])stow([^[:alnum:]]|$)|flatpak update --noninteractive' Containerfile build_files files .github; then \
      echo 'forbidden Stow or system Flatpak update reference detected' >&2; \
      exit 1; \
    fi
    @test -e .github/workflows/build.yml
    @test -e cosign.pub
    @test ! -e disk_config
    @test ! -e image.toml
    @test ! -e artifacthub-repo.yml

image-build:
    sudo podman build --pull=newer --tag {{ image }} .

switch-local:
    sudo bootc switch --transport containers-storage {{ image }}

switch-ghcr:
    sudo bootc switch {{ remote_image }}
