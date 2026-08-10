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
    @test -e .github/workflows/build.yml
    @test -e cosign.pub

image-build:
    sudo podman build --pull=newer --tag {{ image }} .

switch-local:
    sudo bootc switch --transport containers-storage {{ image }}

switch-ghcr:
    sudo bootc switch {{ remote_image }}
