set dotenv-filename := "image-template.env"
set dotenv-load
set shell := ["bash", "-euo", "pipefail", "-c"]

export image_name := env_var("IMAGE_NAME")
export repo_organization := env_var("REPO_ORGANIZATION")
export image_desc := env_var("IMAGE_DESC")
export image_keywords := env_var("IMAGE_KEYWORDS")
export image_logo_url := env_var("IMAGE_LOGO_URL")
export default_tag := env_var("DEFAULT_TAG")

image := "localhost/ammix-os:dev"
remote_image := "ghcr.io/ammix/ammix-os:latest"

default:
    @just --list

fmt:
    shfmt -w build_files/*
    just --fmt --unstable

check:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r file; do
        just --unstable --fmt --check -f "$file"
    done < <(find . -type f -name "*.just" -print)
    just --unstable --fmt --check -f Justfile
    shfmt -d build_files/*
    shellcheck -x -P build_files build_files/build.sh build_files/build-initramfs.sh build_files/finalize.sh build_files/kargs.sh
    [[ "$(tail -n 1 Containerfile)" == "RUN bootc container lint" ]]
    [[ -e .github/workflows/build.yml ]]
    [[ -e cosign.pub ]]

build target_image=image_name tag=default_tag:
    #!/usr/bin/env bash
    set -euo pipefail

    labels=()
    if [[ -z "$(git status --short)" ]]; then
        git_sha="$(git rev-parse --short HEAD)"
        labels+=("--label" "io.artifacthub.package.readme-url=https://raw.githubusercontent.com/{{ repo_organization }}/{{ image_name }}/${git_sha}/README.md")
        labels+=("--label" "org.opencontainers.image.documentation=https://raw.githubusercontent.com/{{ repo_organization }}/{{ image_name }}/${git_sha}/README.md")
        labels+=("--label" "org.opencontainers.image.source=https://github.com/{{ repo_organization }}/{{ image_name }}/blob/${git_sha}/Containerfile")
        labels+=("--label" "org.opencontainers.image.url=https://github.com/{{ repo_organization }}/{{ image_name }}/tree/${git_sha}")
        labels+=("--label" "org.opencontainers.image.version={{ default_tag }}.$(date +%Y%m%d)-${git_sha}")
    fi

    labels+=("--label" "io.artifacthub.package.deprecated=false")
    labels+=("--label" "io.artifacthub.package.keywords={{ image_keywords }}")
    labels+=("--label" "io.artifacthub.package.license=Apache-2.0")
    labels+=("--label" "io.artifacthub.package.logo-url={{ image_logo_url }}")
    labels+=("--label" "io.artifacthub.package.prerelease=false")
    labels+=("--label" "org.opencontainers.image.created=$(date -u +%Y-%m-%dT%H:%M:%SZ)")
    labels+=("--label" "org.opencontainers.image.description={{ image_desc }}")
    labels+=("--label" "org.opencontainers.image.title={{ image_name }}")
    labels+=("--label" "org.opencontainers.image.vendor={{ repo_organization }}")

    podman build "${labels[@]}" --pull=newer --tag "${target_image}:${tag}" --file Containerfile .

ostree-rechunk target_image=image_name tag=default_tag:
    #!/usr/bin/env bash
    set -euo pipefail

    [[ "${UID}" -eq 0 ]]
    chunker_image="localhost/${target_image}:${tag}"

    podman run --rm \
        --pull=never \
        --privileged \
        -v /var/lib/containers:/var/lib/containers \
        --entrypoint /usr/bin/rpm-ostree \
        "${chunker_image}" \
        compose build-chunked-oci \
        --max-layers 127 \
        --format-version=2 \
        --bootc \
        --from "localhost/${target_image}:${tag}" \
        --output "containers-storage:localhost/${target_image}:${tag}"

generate-default-tag tag=default_tag:
    @echo "{{ tag }}"

generate-build-tags target_image=image_name tag=default_tag:
    #!/usr/bin/env bash
    set -euo pipefail

    date_tag="$(date -u +%Y%m%d)"
    tags=()
    if [[ -z "$(git status --short)" ]]; then
        git_sha="$(git rev-parse --short HEAD)"
        tags+=("${tag}-${git_sha}")
        tags+=("${tag}-${date_tag}-${git_sha}")
        tags+=("${date_tag}-${git_sha}")
    fi
    tags+=("${date_tag}")
    tags+=("${tag}")
    tags+=("${tag}-${date_tag}")

    echo "${tags[*]}"

tag-images target_image=image_name tag=default_tag tags="":
    #!/usr/bin/env bash
    set -euo pipefail

    image_id="$(podman inspect "${target_image}:${tag}" | jq -r '.[].Id')"
    podman untag "${image_id}"
    for alias_tag in {{ tags }}; do
        podman tag "${image_id}" "${target_image}:${alias_tag}"
    done

[private]
image_name:
    @echo "{{ image_name }}"

image-build:
    sudo podman build --pull=newer --tag {{ image }} .

switch-local:
    sudo bootc switch --transport containers-storage {{ image }}

switch-ghcr:
    sudo bootc switch {{ remote_image }}
