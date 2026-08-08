ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/cosmic-atomic
ARG FEDORA_VERSION=44

FROM scratch AS ctx
COPY build_files /
COPY files /files/

FROM ${BASE_IMAGE}:${FEDORA_VERSION}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build && \
    /ctx/kargs && \
    /ctx/build-initramfs && \
    /ctx/finalize

RUN bootc container lint
