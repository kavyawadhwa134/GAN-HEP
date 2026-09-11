# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=quay.io/jupyter/base-notebook:latest
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG NB_UID=1000
ARG BUILD_JOBS=8

USER root

COPY binder/apt.txt /tmp/cardinal-apt.txt
RUN apt-get update --yes \
 && DEBIAN_FRONTEND=noninteractive xargs -a /tmp/cardinal-apt.txt \
      apt-get install --yes --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/cardinal-apt.txt

USER ${NB_UID}

COPY binder/environment.yml /tmp/cardinal-environment.yml
RUN mamba env update --name base --file /tmp/cardinal-environment.yml \
 && mamba clean --all --force-pkgs-dirs --yes \
 && rm -f /tmp/cardinal-environment.yml

COPY --chown=${NB_UID}:users scripts /opt/cardinal-launcher/scripts
RUN chmod +x /opt/cardinal-launcher/scripts/*.sh \
 && ln -s /opt/cardinal-launcher /home/jovyan/cardinal-launcher

ENV CARDINAL_ROOT=/home/jovyan/cardinal \
    CARDINAL_DIR=/home/jovyan/cardinal \
    NEKRS_HOME=/home/jovyan/cardinal/install \
    OCCA_CACHE_DIR=/home/jovyan/.cache/occa \
    NEKRS_OCCA_MODE_DEFAULT=CUDA \
    OPENMC_CROSS_SECTIONS=/home/jovyan/cross_sections/endfb-viii.0-hdf5/cross_sections.xml \
    PATH=/home/jovyan/cardinal:/home/jovyan/cardinal/install/bin:${PATH}

# CUDA compilation does not need a GPU. The NVIDIA device and driver are
# injected later when this image runs on an SSL-HEP GPU worker.
RUN CARDINAL_REQUIRE_GPU=0 \
    BUILD_JOBS=${BUILD_JOBS} \
    /opt/cardinal-launcher/scripts/build-cardinal.sh

RUN /home/jovyan/cardinal/cardinal-opt --version \
 && test -x /home/jovyan/cardinal/install/bin/openmc \
 && test -x /home/jovyan/cardinal/install/bin/nekrs

WORKDIR /home/jovyan

LABEL org.opencontainers.image.source="https://github.com/kavyawadhwa134/GAN-HEP" \
      org.opencontainers.image.description="CARDINAL, MOOSE, OpenMC, and CUDA-enabled NekRS for SSL-HEP Binder"
