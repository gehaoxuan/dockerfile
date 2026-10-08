FROM ubuntu:22.04

USER root
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        clang \
        clangd \
        cmake \
        curl \
        git \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libzstd-dev \
        lld \
        llvm \
        net-tools \
        ninja-build \
        openssh-server \
        pkg-config \
        tmux \
        unzip \
        vim \
        wget \
        xz-utils \
        zip \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

RUN wget -q https://repo.huaweicloud.com/python/3.11.15/Python-3.11.15.tar.xz && \
    tar -xf Python-3.11.15.tar.xz && \
    cd Python-3.11.15 && \
    ./configure --enable-shared \
        LDFLAGS="-Wl,-rpath,/usr/local/python3.11.15/lib" \
        --prefix=/usr/local/python3.11.15 && \
    make -j"$(nproc)" && \
    make altinstall && \
    ln -sf python3.11 /usr/local/python3.11.15/bin/python3 && \
    ln -sf pip3.11 /usr/local/python3.11.15/bin/pip3 && \
    ln -sf python3 /usr/local/python3.11.15/bin/python && \
    ln -sf pip3 /usr/local/python3.11.15/bin/pip && \
    cd /root && rm Python-3.11.15.tar.xz && rm -rf Python-3.11.15

ENV PATH=/usr/local/python3.11.15/bin:$PATH

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL

RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    chmod +x Ascend-cann-toolkit.run && \
    chmod +x Ascend-cann-ops.run && \
    ./Ascend-cann-toolkit.run --quiet --install && \
    ./Ascend-cann-ops.run --quiet --install && \
    rm Ascend-cann-toolkit.run Ascend-cann-ops.run

# ModelArts convention: run as ma-user (uid 1000) in ma-group (gid 100)
RUN default_user=$(getent passwd 1000 | awk -F ':' '{print $1}') || echo "uid: 1000 does not exist" && \
    default_group=$(getent group 100 | awk -F ':' '{print $1}') || echo "gid: 100 does not exist" && \
    if [ ! -z ${default_user} ] && [ ${default_user} != "ma-user" ]; then \
        userdel -r ${default_user}; \
    fi && \
    if [ ! -z ${default_group} ] && [ ${default_group} != "ma-group" ]; then \
        groupdel -f ${default_group}; \
    fi && \
    groupadd -g 100 ma-group && useradd -d /home/ma-user -m -u 1000 -g 100 -s /bin/bash ma-user && \
    # Grant the read, write, and execute permissions on the target directory to the user ma-user.
    chmod -R 750 /home/ma-user && \
    echo 'source /usr/local/Ascend/cann/set_env.sh' >> /home/ma-user/.bashrc

USER ma-user

WORKDIR /home/ma-user

CMD ["/bin/bash"]
