# Vars
ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/cosmic-atomic
ARG FEDORA_VERSION=42

FROM scratch AS ctx
COPY build_files /
COPY files /files/

# Base Image
FROM ${BASE_IMAGE}:${FEDORA_VERSION}

# Install packages and finalize build
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build && \
    /ctx/build-initramfs && \
    /ctx/finalize

# Verify final image and contents are correct.
RUN bootc container lint
