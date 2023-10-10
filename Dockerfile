# syntax=docker/dockerfile:1.6
ARG BASE_IMAGE=ubuntu:20.04
ARG BASE_RUNTIME_IMAGE=nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

FROM ${BASE_IMAGE} AS python-env

ARG DEBIAN_FRONTEND=noninteractive
ARG PIP_NO_CACHE_DIR=1
ARG PYENV_VERSION=v2.3.28
ARG PYTHON_VERSION=3.10.13

RUN <<EOF
    set -eu

    apt-get update

    apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        curl \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
        git

    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
    set -eu

    git clone https://github.com/pyenv/pyenv.git /opt/pyenv
    cd /opt/pyenv
    git checkout "${PYENV_VERSION}"

    PREFIX=/opt/python-build /opt/pyenv/plugins/python-build/install.sh
    /opt/python-build/bin/python-build -v "${PYTHON_VERSION}" /opt/python

    rm -rf /opt/python-build /opt/pyenv
EOF


FROM ${BASE_RUNTIME_IMAGE} AS runtime-env

ARG DEBIAN_FRONTEND=noninteractive
ARG PIP_NO_CACHE_DIR=1
ENV PYTHONUNBUFFERED=1
ENV PATH=/home/user/.local/bin:/opt/python/bin:${PATH}

COPY --from=python-env /opt/python /opt/python

RUN <<EOF
    set -eu

    apt-get update
    apt-get install -y \
        git \
        libgl1 \
        libglib2.0-0 \
        wget \
        gosu
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
    set -eu

    groupadd -o -g 1000 user
    useradd -m -o -u 1000 -g user user
EOF

ARG ANI_SEG_URL=https://github.com/SkyTNT/anime-segmentation
ARG ANI_SEG_VERSION=2373527d745755fbe2987ba146d9326fed8e8881

RUN <<EOF
    set -eu

    mkdir -p /code
    chown -R user:user /code

    gosu user git clone "${ANI_SEG_URL}" /code/anime-segmentation
    cd /code/anime-segmentation
    gosu user git checkout "${ANI_SEG_VERSION}"
EOF

WORKDIR /code/anime-segmentation
ADD ./requirements.txt /code/anime-segmentation/
RUN <<EOF
    set -eu

    gosu user pip3 install -r ./requirements.txt
EOF

ENTRYPOINT [ "gosu", "user", "python3", "inference.py" ]
