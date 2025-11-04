# Vars
ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/silverblue
ARG FEDORA_VERSION=42

FROM scratch AS ctx
COPY build_files /
COPY files /files/

# Base Image
FROM ${BASE_IMAGE}:${FEDORA_VERSION}

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop, vivaldi, filen.
##
## This makes /opt immutable and be able to be used by the package manager.
RUN rm /opt && mkdir /opt

# Install packages and finalize build
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build && \
    /ctx/akmods && \
    /ctx/kargs && \
    /ctx/build-initramfs && \
    /ctx/finalize

# Verify final image and contents are correct.
RUN bootc container lint
