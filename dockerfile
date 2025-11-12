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


# COPY submodules/ /tmp/submodules/
# RUN pip install /tmp/submodules/diff-gaussian-rasterization_ms
# RUN pip install /tmp/submodules/diff-gaussian-rasterization
# RUN pip install /tmp/submodules/diff-gaussian-rasterization_gof
# RUN pip install /tmp/submodules/simple-knn
# RUN pip install /tmp/submodules/fused-ssim
# RUN pip install /tmp/submodules/nvdiffrast

