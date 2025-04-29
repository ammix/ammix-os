# Allow build scripts to be referenced without being copied into the final image

# Vars
ARG BASE_IMAGE=cosmic-atomic-main
ARG FEDORA_VERSION=42

FROM scratch AS ctx
COPY build_files /

FROM scratch AS stage-files
COPY ./files /files

# Stage for akmods RPMs
FROM ghcr.io/ublue-os/akmods:main-${FEDORA_VERSION} AS akmods

# Base Image
FROM ghcr.io/ublue-os/${BASE_IMAGE}:${FEDORA_VERSION}

# Copy files
RUN --mount=type=bind,from=stage-files,src=/files,dst=/tmp/files \
    if [ -d /tmp/files/etc ]; then cp -a /tmp/files/etc/. /etc/; fi && \
    if [ -d /tmp/files/usr ]; then cp -a /tmp/files/usr/. /usr/; fi && \
    echo "File copy complete." && \
    ostree container commit

# Install akmods
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/akmods && \
    /ctx/cleanup

# Install packages and finalize build
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    /ctx/build-initramfs && \
    /ctx/finalize

# Verify final image and contents are correct.
RUN bootc container lint
