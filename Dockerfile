FROM ubuntu:22.04

ARG MUJOCO_VERSION=3.10.0
ENV MUJOCO_VERSION=${MUJOCO_VERSION}
ENV DEBIAN_FRONTEND=noninteractive

# Build essentials
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    cmake \
    build-essential \
    libeigen3-dev \
    libyaml-cpp-dev \
    libspdlog-dev \
    libboost-all-dev \
    libglfw3-dev \
    nlohmann-json3-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build Unitree SDK2
RUN git clone https://github.com/unitreerobotics/unitree_sdk2.git /opt/unitree_robotics/unitree_sdk2 && \
    cd /opt/unitree_robotics/unitree_sdk2 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/opt/unitree_robotics && \
    make install

# Install MuJoCo
RUN mkdir -p /root/.mujoco && \
    wget -q https://github.com/google-deepmind/mujoco/releases/download/${MUJOCO_VERSION}/mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz \
      -O /tmp/mujoco.tar.gz && \
    tar -xzf /tmp/mujoco.tar.gz -C /root/.mujoco && \
    rm /tmp/mujoco.tar.gz

# Install unitree_mujoco and build the simulator
RUN git clone https://github.com/unitreerobotics/unitree_mujoco.git /opt/unitree_mujoco && \
    ln -s /root/.mujoco/mujoco-${MUJOCO_VERSION} /opt/unitree_mujoco/simulate/mujoco && \
    cd /opt/unitree_mujoco/simulate && \
    mkdir build && cd build && \
    cmake .. && make -j4

RUN printf '#!/bin/bash\n\
export LD_LIBRARY_PATH=/root/.mujoco/mujoco-%s/lib:$LD_LIBRARY_PATH\n\
exec "$@"\n' "${MUJOCO_VERSION}" > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /opt/unitree_mujoco/simulate/build

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]