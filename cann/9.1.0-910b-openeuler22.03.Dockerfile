FROM openeuler/openeuler:22.03

USER root

WORKDIR /root

# Create ma-user with specific UID/GID for ModelArts compatibility
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
    chmod -R 750 /home/ma-user

RUN yum update -y && \
    yum install -y \
        ccache \
        cmake \
        gcc \
        gcc-c++ \
        git \
        htop \
        make \
        ninja-build \
        python3 \
        python3-pip \
        spdlog \
        sudo \
        tmux \
        tree \
        vim \
        wget


RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet https://ascend-cann-open.obs.cn-north-4.myhuaweicloud.com/CANN/CANN%209.1.0/Ascend-cann_9.1.0_linux-aarch64.run && \
    bash ./Ascend-cann_9.1.0_linux-aarch64.run --quiet --install && \
    wget --quiet https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%209.1.0/Ascend-cann-910b-ops_9.1.0_linux-aarch64.run && \
    bash ./Ascend-cann-910b-ops_9.1.0_linux-aarch64.run --quiet --install && \
    source /usr/local/Ascend/cann/set_env.sh && \
    echo 'source /usr/local/Ascend/cann/set_env.sh' >> /home/ma-user/.bashrc && \
    wget --quiet https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%209.1.0/Ascend-cann-nnal_9.1.0_linux-aarch64.run && \
    bash ./Ascend-cann-nnal_9.1.0_linux-aarch64.run --quiet --install && \
    source /usr/local/Ascend/nnal/atb/set_env.sh && \
    echo 'source /usr/local/Ascend/nnal/atb/set_env.sh' >> /home/ma-user/.bashrc && \
    rm ./Ascend-cann_9.1.0_linux-aarch64.run && \
    rm ./Ascend-cann-910b-ops_9.1.0_linux-aarch64.run && \
    rm ./Ascend-cann-nnal_9.1.0_linux-aarch64.run

USER ma-user

WORKDIR /home/ma-user

RUN wget https://mirrors.nju.edu.cn/anaconda/miniconda/Miniconda3-py310_26.3.2-2-Linux-aarch64.sh && \
    bash Miniconda3-py310_26.3.2-2-Linux-aarch64.sh -b -p /home/ma-user/miniconda3 && \
    /home/ma-user/miniconda3/bin/conda init bash && \
    /home/ma-user/miniconda3/bin/conda tos accept && \
    rm Miniconda3-py310_26.3.2-2-Linux-aarch64.sh

ENV PATH=/home/ma-user/miniconda3/bin:$PATH
