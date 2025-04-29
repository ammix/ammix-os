# Allow build scripts to be referenced without being copied into the final image

# Vars
ARG BASE_IMAGE=cosmic-atomic-main
ARG FEDORA_VERSION=42

FROM scratch AS ctx
COPY build_files /

FROM scratch AS stage-files
COPY ./files /files

# Base Image
FROM ghcr.io/ublue-os/${BASE_IMAGE}:${FEDORA_VERSION}

RUN --mount=type=bind,from=stage-files,src=/files,dst=/tmp/files \
    if [ -d /tmp/files/etc ]; then cp -a /tmp/files/etc/. /etc/; fi && \
    if [ -d /tmp/files/usr ]; then cp -a /tmp/files/usr/. /usr/; fi && \
    echo "File copy complete." && \
    ostree container commit

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.
ARG FEDORA_VERSION

COPY --from=ghcr.io/ublue-os/akmods:main-${FEDORA_VERSION} /rpms/ /tmp/rpms
RUN find /tmp/rpms
RUN rpm-ostree install /tmp/rpms/kmods/*openrazer*.rpm

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    /ctx/build-initramfs && \
    /ctx/finalize

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
