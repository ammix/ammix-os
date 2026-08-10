ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/cosmic-atomic
ARG FEDORA_VERSION=44

FROM scratch AS ctx
COPY build_files /
COPY files /files/

FROM ${BASE_IMAGE}:${FEDORA_VERSION}
ARG FEDORA_VERSION

# Vivaldi and Filen install under /opt; the mutable /var/opt target would omit their payload from deployments.
RUN if [ -L /opt ]; then rm /opt && mkdir /opt; fi

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    /ctx/kargs.sh && \
    FEDORA_VERSION="${FEDORA_VERSION}" /ctx/build-initramfs.sh && \
    /ctx/finalize.sh

RUN bootc container lint
