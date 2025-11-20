FROM nvidia/cuda:12.4.0-devel-ubuntu22.04
ARG DEBIAN_FRONTEND=noninteractive


WORKDIR /app


# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    libboost-program-options-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libeigen3-dev \
    libflann-dev \
    libfreeimage-dev \
    libmetis-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libgmock-dev \
    libsqlite3-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libsuitesparse-dev \
    libatlas-base-dev \
    libabsl-dev \
    wget \
    curl \
    python3-pip \
    python3-tk \
    tk-dev


ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# for GLEW
ENV LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH
RUN ln -s /usr/bin/python3 /usr/bin/python
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.4/targets/x86_64-linux/lib:$LD_LIBRARY_PATH
ENV CPATH=/usr/local/cuda-12.4/targets/x86_64-linux/include:$CPATH
ENV PATH=/usr/local/cuda-12.4/bin:$PATH

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN rm -rf /tmp/requirements.txt

ENV NVDIFRAST_BACKEND=cuda
ENV MILO_MESH_RES_SCALE=0.3
ENV MILO_RAST_TRI_CHUNK=150000


# Install CMake
RUN wget https://cmake.org/files/v3.31/cmake-3.31.4-linux-x86_64.tar.gz
RUN tar -zxvf cmake-3.31.4-linux-x86_64.tar.gz
RUN mv cmake-3.31.4-linux-x86_64 /opt/cmake-3.31.4
ENV PATH="/opt/cmake-3.31.4/bin:${PATH}"

# Install CUDSS
RUN wget https://developer.download.nvidia.com/compute/cudss/redist/libcudss/linux-x86_64/libcudss-linux-x86_64-0.6.0.5_cuda12-archive.tar.xz && \
    mkdir -p /tmp/cudss && \
    tar -xJf libcudss-linux-x86_64-0.6.0.5_cuda12-archive.tar.xz -C /tmp/cudss --strip-components=1 && \
    cp -r /tmp/cudss/lib/ /usr/local/cuda/ && \
    cp -r /tmp/cudss/include/* /usr/local/cuda/include/ && \
    rm -rf /tmp/cudss libcudss-linux-x86_64-0.6.0.5_cuda12-archive.tar.xz

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/lib:$LD_LIBRARY_PATH

# Download and build Ceres Solver with CUDA support
WORKDIR /app
RUN git clone --recursive https://github.com/ceres-solver/ceres-solver.git
WORKDIR /app/ceres-solver
RUN git checkout 93e66f0
RUN mkdir build
WORKDIR build
RUN cmake .. -G Ninja \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_TESTING=OFF \
 -DBUILD_EXAMPLES=OFF \
 -DCERES_USE_CUDA=ON \
 -DCERES_USE_CUDSS=ON | tee /tmp/ceres_cmake.log
RUN ninja
RUN ninja install
WORKDIR /app

# Install GLOMAP
RUN git clone https://github.com/colmap/glomap.git
WORKDIR glomap
RUN git checkout 4f475de
RUN mkdir build
WORKDIR build
RUN cmake .. -GNinja
RUN ninja && ninja install
WORKDIR ../../

# Install COLMAP
RUN git clone https://github.com/colmap/colmap.git
WORKDIR colmap
RUN git checkout f8edcca
RUN mkdir build
WORKDIR build
RUN cmake .. -GNinja
RUN ninja && ninja install
WORKDIR ../../


# COPY submodules/ /tmp/submodules/
# RUN pip install /tmp/submodules/diff-gaussian-rasterization_ms
# RUN pip install /tmp/submodules/diff-gaussian-rasterization
# RUN pip install /tmp/submodules/diff-gaussian-rasterization_gof
# RUN pip install /tmp/submodules/simple-knn
# RUN pip install /tmp/submodules/fused-ssim
# RUN pip install /tmp/submodules/nvdiffrast

